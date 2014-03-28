#!/usr/bin/perl
# Generate a list of potential confirmation pages to brute force with a tool 
# like wget/wfuzz/burp. Useful if you're pentesting a payement gateway that 
# uses a hidden payment confirmation page which is accessed by the payment 
# gateway and not intended for public access.
# Written by Eldar "Wireghoul" Marcussen - justanotherhacker.com
# Blackhat Asia 2014 Proof of concept release

# Usage: perl returnbrute.pl <prefix>
# Example:
# perl returnbrute.pl > loadinburp.txt
# perl returnbrute.pl 'http://vuln.com' | xargs -n1 wget 

my @dirs = (
    '/',
    '/inc/',
    '/include/',
    '/include/pay/',
    '/includes/',
    '/includes/pay/',
    '/lib/',
    '/libraries/',
    '/module/',
    '/module/pay/',
    '/modules/',
    '/modules/pay/',
    '/payment/',
    '/shop/',
    '/store/',
    '/svc/',
    '/servlet/',
    '/cgi/',
    '/cgi-bin/',
    '/cgibin/',
);

my @files = (
    'pay',
    'payment',
    'success',
    'paymentsuccess',
    'paymentcomplete',
    'paymentsuccessful',
    'successful',
    'paid',
    'return',
    'valid',
    'validpay',
    'validate',
    'validatepayment',
    'validatepay',
    'validation',
    'complete',
    'completepay',
    'completepayment',
    'trxcomplete',
    'transactioncomplete',
    'final',
    'finished',
);

my @exts  = (
    '',
    '.php',
    '.asp',
    '.aspx',
    '.jsp',
    '.py',
    '.pl',
    '.rb',
    '.cgi',
    '.php3',
    '.php4',
    '.php5',
);

foreach my $dir (@dirs) {
    foreach my $file (@files) {
        foreach my $ext (@exts) {
            print "$ARGV[0]$dir$file$ext\n";
        }
    }
}
