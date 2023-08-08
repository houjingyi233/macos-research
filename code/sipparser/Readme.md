### Project Zero Bug 2440 
The was a use-after-free vulnerability in libIPTelephony.dylib inside the SIP message decoder (SipMessageDecoder::decode() function). 

Google Project Zero wrote code that I've modified for Fuzzing, attached is the baseline .cpp.

// REPRODUCTION:
// Compile:
// clang++ -g -o ZN20SipMultiStringHeader18setValueFromStringERKNSt3__112basic_stringIcNS0_11char_traitsIcEENS0_9allocatorIcEEEE ZN20SipMultiStringHeader18setValueFromStringERKNSt3__112basic_stringIcNS0_11char_traitsIcEENS0_9allocatorIcEEEE.cpp
//
