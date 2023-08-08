### Project Zero Bug 2440 
The was a use-after-free vulnerability in libIPTelephony.dylib inside the SIP message decoder (SipMessageDecoder::decode() function). 

Google Project Zero wrote code that I've modified for Fuzzing, attached is the baseline .cpp.

