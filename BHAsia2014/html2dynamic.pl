#!/usr/bin/perl

use strict;
use warnings;
use HTML::Form;

my $html =eval { local $/; open my $fh, "$ARGV[0]"; return <$fh>; close($fh); };
$html =~ m/(<h3>Credit Card Payment.*?<\/form>)/ms;
my $mwform = $1;
my $form = HTML::Form->parse($mwform, 'file:///');
my $merchantID = $form->find_input('merchantUUID')->value;
my $amount = $form->find_input('transactionAmount')->value;
my $hash = $form->find_input('hash')->value;
my $salt = $form->find_input('hashSalt')->value;
my $currency = $form->find_input('transactionCurrency')->value;
my $notifyurl = $form->find_input('notifyURL')->value;
my $cartID = $form->find_input('custom1')->value;
my $cartAmt = $form->find_input('custom2')->value;
print '$dynamic_1011$'."$hash".'$'.lc("$merchantID$amount$currency").'$$'."2\n";
