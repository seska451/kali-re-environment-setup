# Kali based Reverse Engineering Environment setup scripts

Nothing special, just a bash script to up an virtual machine the way I need it. While I put some continuation checks in to the script, I do not gaurantee that it is idempotent. I.e. if you run it more than once, be careful that it doesn't do something 'twice' that you don't want it to - like append text to a network file.

# Tested on
- Kali Rolling 2024.2 circa Aug 2024.

# Usage
1. Download kali-setup.sh to your Kali 2024.2 instance
2. Open a bash prompt and cd into the directory you downloaded the file in step 1.
3. run `chmod +x ./kali-setup.sh`
4. run `./kali-setup.sh` and follow the on screen prompts

Note: depending on your machine, may take over 30 minutes to finish on a fresh VM.

# Contributions & Issue reports
If, in the future there are bugs (likely!), feel free to report them for the sake of others, however, I can't garauntee I will have time to support this repo long term.

I'll happily accept PR's, but consider fork and run with it yourself if thats faster.
