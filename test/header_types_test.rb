require "aws-eventstream"
require "stringio"

original = File.binread(__dir__ + "/fixtures/encoded/positive/all_headers")
message, _eof = Aws::EventStream::Decoder.new(format: false).decode_chunk(original)
message.headers.keys.sort.each do |key|
  one = Aws::EventStream::Message.new(headers: { key => message.headers[key] }, payload: StringIO.new(""))
  puts "#{key} #{message.headers[key].type}: #{Aws::EventStream::Encoder.new.encode(one).unpack1("H*")}"
end
