package http

import "core:fmt"
import "core:net"
import "core:strconv"
import "core:strings"

HTTP_Response :: struct {
    status_code: int,
    body:        string,
    headers:     map[string]string,
    ok:          bool,
}

get :: proc(url: string, headers: map[string]string = nil) -> HTTP_Response {
    return _http_request("GET", url, "", headers)
}

pst :: proc(url: string, body: string, headers: map[string]string = nil) -> HTTP_Response {
    return _http_request("POST", url, body, headers)
}

put :: proc(url: string, body: string, headers: map[string]string = nil) -> HTTP_Response {
    return _http_request("PUT", url, body, headers)
}

del :: proc(url: string, headers: map[string]string = nil) -> HTTP_Response {
    return _http_request("DELETE", url, "", headers)
}

// Parse URL into host, port, path
@(private)
_parse_url :: proc(url: string) -> (host: string, port: int, path: string, ok: bool) {
    url_copy := url

    // Remove protocol
    if strings.has_prefix(url_copy, "http://") {
        url_copy = url_copy[7:]
        port = 80
    } else if strings.has_prefix(url_copy, "https://") {
        // HTTPS not supported with raw sockets (need TLS)
        return "", 0, "", false
    } else {
        port = 80
    }

    // Split host and path
    slash_idx := strings.index(url_copy, "/")
    if slash_idx == -1 {
        host = url_copy
        path = "/"
    } else {
        host = url_copy[:slash_idx]
        path = url_copy[slash_idx:]
    }

    // Check for port in host
    colon_idx := strings.index(host, ":")
    if colon_idx != -1 {
        port_str := host[colon_idx + 1:]
        host = host[:colon_idx]
        port_val, parse_ok := strconv.parse_int(port_str)
        if parse_ok {
            port = port_val
        }
    }

    return host, port, path, true
}

@(private)
_http_request :: proc(method: string, url: string, body: string, headers: map[string]string) -> HTTP_Response {
    // Parse URL
    host, port, path, parse_ok := _parse_url(url)
    if !parse_ok {
        fmt.eprintln("Failed to parse URL:", url)
        return HTTP_Response{ok = false}
    }

    // Resolve hostname to IP addresses
    // resolve returns: (ep4, ep6: Endpoint, err: Network_Error)
    ep4, ep6, resolve_err := net.resolve(host)
    if resolve_err != nil {     // Network_Error is union #shared_nil, so check != nil
        fmt.eprintln("Failed to resolve hostname:", host, resolve_err)
        return HTTP_Response{ok = false}
    }

    // Use IPv4 endpoint and override the port
    endpoint := ep4
    endpoint.port = port

    // Connect - returns (TCP_Socket, Network_Error)
    socket, dial_err := net.dial_tcp(endpoint)
    if dial_err != nil {     // Network_Error can be nil
        fmt.eprintln("Failed to connect:", dial_err)
        return HTTP_Response{ok = false}
    }
    defer net.close(socket)

    // Build HTTP request
    request_builder := strings.builder_make()
    defer strings.builder_destroy(&request_builder)

    // Request line
    fmt.sbprintf(&request_builder, "%s %s HTTP/1.1\r\n", method, path)

    // Host header (required for HTTP/1.1)
    fmt.sbprintf(&request_builder, "Host: %s\r\n", host)

    // Add custom headers
    if headers != nil {
        for key, value in headers {
            fmt.sbprintf(&request_builder, "%s: %s\r\n", key, value)
        }
    }

    // Content-Length for POST/PUT
    if body != "" {
        fmt.sbprintf(&request_builder, "Content-Length: %d\r\n", len(body))
    }

    // Connection close (simplifies response handling)
    fmt.sbprintf(&request_builder, "Connection: close\r\n")

    // End headers
    fmt.sbprintf(&request_builder, "\r\n")

    // Add body
    if body != "" {
        strings.write_string(&request_builder, body)
    }

    request := strings.to_string(request_builder)

    // Send request - returns (bytes_written: int, err: TCP_Send_Error)
    _, send_err := net.send_tcp(socket, transmute([]byte)request)
    if send_err != nil {     // TCP_Send_Error can be nil
        fmt.eprintln("Failed to send request:", send_err)
        return HTTP_Response{ok = false}
    }

    // Receive response
    response_buffer: [dynamic]byte
    defer delete(response_buffer)

    buffer: [4096]byte
    for {
        // recv_tcp returns (bytes_read: int, err: TCP_Recv_Error)
        bytes_read, recv_err := net.recv_tcp(socket, buffer[:])
        if recv_err != nil || bytes_read == 0 {     // TCP_Recv_Error can be nil
            break
        }
        for i in 0 ..< bytes_read {
            append(&response_buffer, buffer[i])
        }
    }

    response_str := string(response_buffer[:])

    // Parse response
    return _parse_http_response(response_str)
}

@(private)
_parse_http_response :: proc(response: string) -> HTTP_Response {
    // Split headers and body
    header_body_split := strings.split(response, "\r\n\r\n")
    defer delete(header_body_split)

    if len(header_body_split) < 1 {
        return HTTP_Response{ok = false}
    }

    header_section := header_body_split[0]
    body_section := ""
    if len(header_body_split) > 1 {
        body_section = strings.join(header_body_split[1:], "\r\n\r\n")
    }
    defer delete(body_section)

    // Parse status line
    lines := strings.split(header_section, "\r\n")
    defer delete(lines)

    if len(lines) == 0 {
        return HTTP_Response{ok = false}
    }

    status_line := lines[0]
    status_parts := strings.split(status_line, " ")
    defer delete(status_parts)

    status_code := 0
    if len(status_parts) >= 2 {
        status_code, _ = strconv.parse_int(status_parts[1])
    }

    // Parse headers
    response_headers := make(map[string]string)
    for i in 1 ..< len(lines) {
        line := lines[i]
        colon_idx := strings.index(line, ":")
        if colon_idx != -1 {
            key := strings.trim_space(line[:colon_idx])
            value := strings.trim_space(line[colon_idx + 1:])
            response_headers[key] = value
        }
    }

    return HTTP_Response {
        status_code = status_code,
        body = strings.clone(body_section),
        headers = response_headers,
        ok = true,
    }
}

// Helper to free response
response_destroy :: proc(resp: ^HTTP_Response) {
    delete(resp.body)
    delete(resp.headers)
}
