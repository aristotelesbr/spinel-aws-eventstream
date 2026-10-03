require "aws-eventstream"

DIR = __dir__ + "/fixtures/encoded/positive"
first = File.binread(DIR + "/int32_header")
second = File.binread(DIR + "/payload_one_str_header")
decoder = Aws::EventStream::Decoder.new(format: false)

message, eof = decoder.decode_chunk(first + second)
puts "#{message.headers.keys.join(",")} #{message.payload.read} eof=#{eof}"
message, eof = decoder.decode_chunk
puts "#{message.headers.keys.join(",")} #{message.payload.read} eof=#{eof}"
message, eof = decoder.decode_chunk
puts "#{message.inspect} eof=#{eof}"

half = Aws::EventStream::Decoder.new(format: false)
message, eof = half.decode_chunk(first[0, 20])
puts "#{message.inspect} eof=#{eof}"
message, eof = half.decode_chunk(first[20, first.bytesize - 20])
puts "#{message.headers.keys.join(",")} #{message.payload.read} eof=#{eof}"

tiny = Aws::EventStream::Decoder.new(format: false)
message, eof = tiny.decode_chunk(first[0, 5])
puts "#{message.inspect} eof=#{eof}"
message, eof = tiny.decode_chunk(first[5, first.bytesize - 5] + second[0, 30])
puts "#{message.headers.keys.join(",")} #{message.payload.read} eof=#{eof}"
message, eof = tiny.decode_chunk(second[30, second.bytesize - 30])
puts "#{message.headers.keys.join(",")} #{message.payload.read} eof=#{eof}"
