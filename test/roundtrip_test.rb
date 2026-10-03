require "aws-eventstream"
require "stringio"

headers = {
  ":event-type" => Aws::EventStream::HeaderValue.new(value: "Records", type: "string"),
  "seq" => Aws::EventStream::HeaderValue.new(value: 7, type: "integer"),
  "kéy" => Aws::EventStream::HeaderValue.new(value: "vé", type: "string")
}
bytes = Aws::EventStream::Encoder.new.encode(Aws::EventStream::Message.new(headers: headers, payload: StringIO.new("hello")))
puts bytes.bytesize
puts bytes.encoding
puts bytes.unpack1("H*")
message, eof = Aws::EventStream::Decoder.new(format: false).decode_chunk(bytes)
message.headers.keys.sort.each { |k| puts "#{k.inspect} #{message.headers[k].type} #{message.headers[k].value.inspect}" }
puts message.payload.read
puts eof

def show(headers, payload)
  message = Aws::EventStream::Message.new(headers: headers, payload: StringIO.new(payload))
  bytes = Aws::EventStream::Encoder.new.encode(message)
  puts "#{bytes.bytesize} #{bytes.encoding} #{bytes.unpack1("H*")}"
  decoded, eof = Aws::EventStream::Decoder.new(format: false).decode_chunk(bytes)
  decoded.headers.keys.sort.each { |k| puts "  #{k.inspect} #{decoded.headers[k].type} #{decoded.headers[k].value.inspect}" }
  puts "  payload #{decoded.payload.read.unpack1("H*")} eof=#{eof}"
end

nul = [0].pack("C")
show({
  "byte" => Aws::EventStream::HeaderValue.new(value: -49, type: "byte"),
  "short" => Aws::EventStream::HeaderValue.new(value: 42, type: "short"),
  "long" => Aws::EventStream::HeaderValue.new(value: 42424242, type: "long"),
  "bytes" => Aws::EventStream::HeaderValue.new(value: "a" + nul + "b", type: "bytes"),
  "time" => Aws::EventStream::HeaderValue.new(value: 8675309, type: "timestamp"),
  "uuid" => Aws::EventStream::HeaderValue.new(value: (0..15).to_a.pack("C*"), type: "uuid"),
  "k" + nul => Aws::EventStream::HeaderValue.new(value: nul + "v", type: "string")
}, "p" + nul + "q")
show({}, "")
