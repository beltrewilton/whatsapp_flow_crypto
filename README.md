# WhatsappFlowCrypto

If you want to implement a [WhatsApp Flow-Endpoint](https://developers.facebook.com/docs/whatsapp/flows/guides/implementingyourflowendpoint)
you need to implement the specified workflow to [decrypt the request and encrypt the response.](https://developers.facebook.com/docs/whatsapp/flows/guides/implementingyourflowendpoint#request-decryption-and-encryption)

For many tasks you can use the Erlang [`crypto`](https://www.erlang.org/doc/apps/crypto/crypto.html) module, but unfortunately this is not possible at the time of writing 
in this case because the necessary configuration of the block cipher is not supported:

To decrypt the AES key you need 

> RSA/ECB/OAEPWithSHA-256AndMGF1Padding algorithm with SHA256 as a hash function for MGF1;

Once the AES key is decrypted we can do the rest of the workflow using the `crypto` module.

This package contains a Rust implementation to decrypt the encrypted AES key. With the help 
of [Rustler](https://github.com/rusterlium/rustler) a safe NIF binding is created
and the missing function can be compensated quickly and efficiently.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `whatsapp_flow_crypto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:whatsapp_flow_crypto, "~> 0.1.0"}
  ]
end
```

## Private key

The package provides a function to extract the private key (with or without a password) from a pem string.

To create the private/public key you can use then `openssl` tool. In the following example
we will create an encrypted private key using the AES-128 cipher (**DES3 cipher is not supported anymore**).
The last command exports the private key without encryption.

```bash
openssl genrsa -aes128 -out private.pem 2048
openssl rsa -in private.pem -outform PEM -pubout -out public.pem
openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in private.pem -out unencrypted-private.pem
```

## Basic usage

Loading the private key:
```elixir
{:ok, private_key_pem} = File.read(private_pem_path);
WhatsappFlowCrypto.fetch_private_key(private_key_pem, "test")
{:ok, #Reference<0.1652491651.443678740.227250>}

```
Decrypt the request and encrypt the response:
```elixir
WhatsappFlowCrypto.decrypt_request(private_key_ref, encrypted_aes_key, initial_vector, encrypted_flow_data)
{:ok, {decrypted_body, aes_key, initial_vector}}

WhatsappFlowCrypto.encrypt_response(aes_key, initial_vector, %{"Hello" => "World"})
"KUkRnUDAUKqhiovnQ9RRwmdBjcg87/wh+ZrMtbh8xlx3"
```

For the detail see the `WhatsappFlowCrypto`.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/whatsapp_flow_crypto>.


## A few notes on the tweaks I made to get it running smoothly:

 - Extracted the unencrypted version of my private.pem.
 - Removed all spacing from the keys within the data (the request from Meta).
 - I updated a local copy of the project dependency from :json to jason 1.4 for compatibility.

```shell
 openssl rsa -in private.pem -out private_unencrypted.pem
 ```

```elixir
   # Meta encrypted data 
   data = %{
      "encrypted_flow_data" => "23Oj6TJZsqJiow5YW......oUJxS1X",
      "encrypted_aes_key" => "C7RUBA...qmd2DLCMwdQ==",
      "initial_vector" => "fAkALM....LdQ=="
    }

    encrypted_flow_data = data["encrypted_flow_data"]
    encrypted_aes_key = data["encrypted_aes_key"]
    initial_vector = data["initial_vector"]

    {:ok, private_key_pem} = File.read("certs/private_unencrypted.pem")

    {:ok, ref} = WhatsappFlowCrypto.fetch_private_key(private_key_pem)

    WhatsappFlowCrypto.decrypt_request(ref, encrypted_aes_key, initial_vector, encrypted_flow_data)
```


```elixir
# Response fragment
response =  %{
        "version" => result["version"],
        "action" => result["action"],
        "screen" => "SUCCESS",
        "data" => %{
            "extension_message_response" => %{
                "params" => %{
                    "flow_token" => result["flow_token"]
                }
            }
        }
    }
 
WhatsappFlowCrypto.encrypt_response(aes_key, initial_vector, response)
 
"ytDoGowFRn..."
 ```
