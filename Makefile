PERL6 = mono /Users/colomon/tools/niecza/run/Niecza.exe

test::
	prove -e '$(PERL6) -Ilib' -r t/
	