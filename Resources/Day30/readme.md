# Day 30/40 - What Is DNS ( Domain Name System) 

## Check out the video below for Day30 👇

[![Day 30/40 - What Is DNS ( Domain Name System) ](https://img.youtube.com/vi/fDOoB4k4YSs/sddefault.jpg)](https://youtu.be/fDOoB4k4YSs)

### Key points from the video

- DNS (Domain Name System) translates a name such as `www.example.com` into an IP address.
- What happens when you type a website address in your browser:
  1. The browser and the operating system check their own cache and the `/etc/hosts` file.
  2. If the name is not found, the request goes to the DNS resolver listed in `/etc/resolv.conf` (usually your ISP or a public resolver such as 8.8.8.8).
  3. The resolver asks a root name server, which points it to the TLD name server (for `.com`).
  4. The TLD name server points it to the authoritative name server of the domain.
  5. The authoritative name server returns the IP address, and the resolver caches it for the TTL of the record and returns it to you.

### Common record types

| Record | Purpose |
|---|---|
| A | Name to IPv4 address |
| AAAA | Name to IPv6 address |
| CNAME | Alias from one name to another name |
| MX | Mail server of the domain |
| NS | Name servers of the domain |
| TXT | Free text, used for verification and email policies |

### Important files and commands

```bash
cat /etc/hosts            # local name to IP mappings, checked before DNS
cat /etc/resolv.conf      # the DNS servers and search domains of this machine
cat /etc/nsswitch.conf    # the order in which files and dns are checked

nslookup www.example.com
dig www.example.com
dig +trace www.example.com
```
