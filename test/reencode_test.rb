require "aws-eventstream"

DIR = __dir__ + "/fixtures/encoded/positive"
["all_headers", "empty_message", "int32_header", "payload_no_headers", "payload_one_str_header"].each do |name|
  original = File.binread(DIR + "/" + name)
  message, _eof = Aws::EventStream::Decoder.new(format: false).decode_chunk(original)
  again = Aws::EventStream::Encoder.new.encode(message)
  puts "#{name}: #{again == original.b ? "same bytes" : "DIFFERENT"} (#{again.bytesize})"
end
