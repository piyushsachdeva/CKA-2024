## Task 21/40

In this exercise, you will work with TLS certificates in Kubernetes

### Task details
1. Generate a PKI private key and CSR and name it as learner.key and learner.csr
2. Create a CertificateSigningRequest for learner and set the expiration date to 1 week
3. Make sure to use the encoded value of csr in the request field
4. Approve the csr
5. Retrieve the certificate from the CSR
6. Export the issued certificate from the CertificateSigningRequest to a yaml
7. Redirect the certificate value to learner.crt file after decoding it
8. Verify the steps one more time, we will use these details in the next task.
