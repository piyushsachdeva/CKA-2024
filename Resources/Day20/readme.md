# Day 20/40 - SSL/TLS Explained Simply

## Check out the video below for Day20 👇

[![Day 20/40 - SSL/TLS Explained Simply](https://img.youtube.com/vi/njT5ECuwCTo/sddefault.jpg)](https://youtu.be/njT5ECuwCTo)

### Key points from the video

- **Symmetric encryption** uses one key to both encrypt and decrypt. It is fast, but both sides need the same key, and sending that key over the network is not safe.
- **Asymmetric encryption** uses a key pair. Data encrypted with the public key can only be decrypted with the private key. It is slower, so it is used only at the start of a connection.
- **A certificate** is a public key plus identity details (for example the domain name), signed by a **Certificate Authority (CA)**. The client trusts the certificate because it already trusts the CA that signed it.
- **TLS handshake in short**: the server sends its certificate, the client verifies it against its list of trusted CAs, both sides agree on a symmetric session key using asymmetric cryptography, and the rest of the traffic is encrypted with that session key.
- **mTLS (mutual TLS)**: the client also presents a certificate, so both sides verify each other. This is how the Kubernetes components talk to each other (Day 21).

### Useful commands

```bash
# generate a private key and a certificate signing request (CSR)
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=example.com"

# read a certificate: who it was issued to, who issued it, and when it expires
openssl x509 -in server.crt -text -noout
```
