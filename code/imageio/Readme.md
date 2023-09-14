#### Generic Fuzzer for ImageIO 
The code originated from Google Project Zero
- https://github.com/googleprojectzero/Jackalope/blob/main/examples/ImageIO/imageio.m

## Code Modifications
Removed are the references for Windows to focus on native X86_64 and arm64e Fuzzing

The code adds a few supported file types and cleans up the autorelease pool use.
