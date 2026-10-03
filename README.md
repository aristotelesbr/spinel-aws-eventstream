# aws-eventstream (spinel-aws-eventstream)

The [aws-eventstream](https://rubygems.org/gems/aws-eventstream) gem for
Spinel: the AWS event-stream message encoder and decoder. This is the
**gem's own source**, aws-eventstream 1.4.0, with rewrites only where
Spinel cannot run it as is, and every rewrite marked
`# spinel-aws-eventstream:` in place. `require "aws-eventstream"` and the
names are the gem's.

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

## What was rewritten, and why

`git diff` against the commit "Add the aws-eventstream gem 1.4.0 lib/
verbatim" shows every change. There are two kinds:

| Where | The gem | Here | Why | Remove when |
|---|---|---|---|---|
| `decoder.rb` (2), `encoder.rb` (every join) | `[...].pack('a*...')` | `[...].map(&:b).join`, numbers packed first | Spinel cuts a String at its first NUL there | matz/spinel#7250 is merged |
| `encoder.rb`, `encode_headers` | `next ... if` for boolean headers | `if`/`else` | each boolean header was encoded as nothing (no upstream issue yet) | Spinel is fixed and `test/bool_headers_test.rb` passes with the gem's form |

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
Spinel `3d541fc87`.

## License

Apache-2.0, as the gem. See `LICENSE` and `NOTICE`.
