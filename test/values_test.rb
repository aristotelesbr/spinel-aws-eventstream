require "aws-eventstream"
require "stringio"

puts Aws::EventStream::Types.types.join(",")
Aws::EventStream::Types.types.each do |type|
  pattern, length, index = Aws::EventStream::Types.pattern[type]
  puts "#{type} #{pattern.inspect} #{length.inspect} #{index}"
end

value = Aws::EventStream::HeaderValue.new(value: "Records", type: "string")
puts "#{value.type} #{value.value}"
uuid = Aws::EventStream::HeaderValue.new(value: (1..16).to_a.pack("C*"), type: "uuid", format: true)
puts uuid.value
stamp = Aws::EventStream::HeaderValue.new(value: 8675309, type: "timestamp", format: true)
puts stamp.value.class
puts stamp.value.to_i
raw = Aws::EventStream::HeaderValue.new(value: 8675309, type: "timestamp")
puts raw.value.class
puts raw.value
passthrough = Aws::EventStream::HeaderValue.new(value: "Records", type: "string", format: true)
puts passthrough.value

message = Aws::EventStream::Message.new(headers: { "a" => value }, payload: StringIO.new("hello"))
puts message.headers.keys.join(",")
puts message.payload.read
empty = Aws::EventStream::Message.new({})
puts empty.headers.size
puts empty.payload.read.inspect

puts Aws::EventStream::Errors::PreludeChecksumError.new.message
puts Aws::EventStream::Errors::MessageChecksumError.new.message
puts Aws::EventStream::Errors::IncompleteMessageError.new.message
puts Aws::EventStream::Errors::EventPayloadLengthExceedError.new.message
puts Aws::EventStream::Errors::EventHeadersLengthExceedError.new.message
puts Aws::EventStream::Errors::ReadBytesExceedLengthError.new(10, 4).message

[
  Aws::EventStream::Errors::ReadBytesExceedLengthError,
  Aws::EventStream::Errors::IncompleteMessageError,
  Aws::EventStream::Errors::PreludeChecksumError,
  Aws::EventStream::Errors::MessageChecksumError,
  Aws::EventStream::Errors::EventPayloadLengthExceedError,
  Aws::EventStream::Errors::EventHeadersLengthExceedError
].each { |error| puts error.superclass }
