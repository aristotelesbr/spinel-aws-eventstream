require "aws-eventstream"

DIR = __dir__ + "/fixtures/encoded"
POSITIVE = ["all_headers", "empty_message", "int32_header", "payload_no_headers", "payload_one_str_header"]
NEGATIVE = ["corrupted_header_len", "corrupted_headers", "corrupted_length", "corrupted_payload"]

POSITIVE.each do |name|
  bytes = File.binread(DIR + "/positive/" + name)
  message, eof = Aws::EventStream::Decoder.new(format: false).decode_chunk(bytes)
  puts "#{name}: #{bytes.bytesize} bytes, eof=#{eof}"
  message.headers.keys.sort.each do |key|
    value = message.headers[key]
    puts "  #{key} (#{value.type}) = #{value.value.inspect}"
  end
  puts "  payload = #{message.payload.read.inspect}"
end

NEGATIVE.each do |name|
  bytes = File.binread(DIR + "/negative/" + name)
  begin
    Aws::EventStream::Decoder.new.decode_chunk(bytes)
    puts "#{name}: no error"
  rescue Aws::EventStream::Errors::ReadBytesExceedLengthError, Aws::EventStream::Errors::PreludeChecksumError, Aws::EventStream::Errors::MessageChecksumError => e
    puts "#{name}: #{e.class}: #{e.message}"
  end
end
