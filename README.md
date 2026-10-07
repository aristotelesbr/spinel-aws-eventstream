# aws-eventstream (spinel-aws-eventstream)

The [aws-eventstream](https://rubygems.org/gems/aws-eventstream) gem for
Spinel: the AWS event-stream message encoder and decoder. This is the
**gem's own source**, aws-eventstream 1.4.0, unchanged.
`require "aws-eventstream"` and the names are the gem's.

```ruby
require "aws-eventstream"
require "stringio"

message = Aws::EventStream::Message.new(
  headers: { ":event-type" => Aws::EventStream::HeaderValue.new(value: "Records", type: "string") },
  payload: StringIO.new("hello")
)
bytes = Aws::EventStream::Encoder.new.encode(message)
decoded, eof = Aws::EventStream::Decoder.new(format: false).decode_chunk(bytes)
decoded.payload.read   # => "hello"
```

## No rewrites

The code under `aws-eventstream/` is the gem's lib/ byte for byte (compare
with the commit "Add the aws-eventstream gem 1.4.0 lib/ verbatim"). Version
0.1.0 carried two rewrites, for a `pack` that cut a String at its first NUL
(matz/spinel#7250) and for boolean headers encoded as nothing; Spinel
master fixed both, so 0.1.1 dropped them and needs a Spinel from
`5c78f07e5` (2026-10-07) or later.

## Known gaps

- **`payload.read` is tagged UTF-8 under Spinel.** The Decoder hands the
  payload over as `StringIO.new(bytes)`, and Spinel's `StringIO#read` returns
  UTF-8 even for a binary String (CRuby keeps ASCII-8BIT). The bytes are the
  same; comparing them with `==` to a binary String gives false. Call `.b` on
  the result if you compare bytes.

## Tests

```sh
spin test                  # each test compiled by Spinel against its .expected
sh oracle/run.sh           # the real gem and this package under CRuby 4.0.2
sh oracle/run.sh --write   # regenerate .expected from the real gem
```

The oracle needs [mise](https://mise.jdx.dev) with Ruby 4.0.2 and the gem
installed once: `cd oracle && BUNDLE_GEMFILE=$PWD/Gemfile mise exec ruby@4.0.2 -- bundle install`.

Every `.expected` is the real gem's output. The fixtures in `test/fixtures`
are the official ones from aws-sdk-ruby (see `UPSTREAM`). Tested with
Spinel `5c78f07e5`.

## License

Apache-2.0, as the gem. See `LICENSE` and `NOTICE`.
