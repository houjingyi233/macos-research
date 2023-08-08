### Project Zero Bug 2440 
The was a use-after-free vulnerability in libIPTelephony.dylib inside the SIP message decoder (SipMessageDecoder::decode() function). 

Google Project Zero wrote code that I've modified for Fuzzing, attached is the baseline .cpp.

REPRODUCTION
---------
Compile:
clang++ -g -o ZN20SipMultiStringHeader18setValueFromStringERKNSt3__112basic_stringIcNS0_11char_traitsIcEENS0_9allocatorIcEEEE ZN20SipMultiStringHeader18setValueFromStringERKNSt3__112basic_stringIcNS0_11char_traitsIcEENS0_9allocatorIcEEEE.cpp

#### Updated Crash List
##### SipMessageHeader Class Functions and Destructors:
_ZN15SipMessageHeaderD2Ev
ZN15SipMessageHeaderC2ERKS
ZN15SipMessageHeaderaSERKS
##### SipContentType Destructor:
_ZN14SipContentTypeD1Ev
##### SipContentLength Destructor:
_ZN16SipContentLengthD1Ev
##### SipMultiStringHeader Functions and Destructors:
_ZN20SipMultiStringHeaderD2Ev
ZN20SipMultiStringHeaderC1ERKS
ZN20SipMultiStringHeaderaSERKS
SipMultiStringHeader::encodeValue(ImsOutStream&) const
##### SipSingleStringHeader Destructor:
_ZN19SipSingleStringHeaderD2Ev
##### libIPTelephony.dylib Functions:
libIPTelephony.dylibims::nextToken(...)
libIPTelephony.dylibImsResult::~ImsResult()+0x1f
libIPTelephony.dylib SipMessageEncodingMap::copyHeadersFromRequestToResponse(SipRequest const&, SipResponse*, bool) const
SipMessageEncodingMap::decodeHeader(...) const
##### SipTimerContainer Function:
SipTimerContainer::cancelAllTimers()
SipTcpConnection Destructor:
SipTcpConnection::~SipTcpConnection()
##### Other
Crash: SIGABRT (EXC_BAD_ACCESS):
Exception Type: EXC_BAD_ACCESS (SIGABRT)
Function Involved: SipPointerVectorHeader<SipAcceptContactValue>::mergeHeader(SipHeader const&) + 47
Relevant Details: Invalid address access, memory-related issue, occurred in thread 0, associated with libIPTelephony.dylib.
