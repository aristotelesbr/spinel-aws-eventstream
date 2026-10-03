require "aws-eventstream"
require "stringio"

def value(v, type)
  Aws::EventStream::HeaderValue.new(value: v, type: type)
end

def show(label, headers)
  bytes = Aws::EventStream::Encoder.new.encode(Aws::EventStream::Message.new(headers: headers, payload: StringIO.new("")))
  puts "#{label}: #{bytes.unpack1("H*")}"
end

yes = value(true, "bool_true")
no = value(false, "bool_false")
text = value("x", "string")
int = value(7, "integer")

show("only booleans", { "a" => yes, "b" => no, "c" => yes })
show("boolean first", { "a" => yes, "s" => text })
show("boolean middle", { "s" => text, "a" => no, "i" => int })
show("boolean last", { "s" => text, "i" => int, "a" => yes })
show("alternating", { "a" => yes, "s" => text, "b" => no, "i" => int, "c" => yes })
