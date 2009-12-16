=HSBC Statement Analyser=

Owen Griffin, 2009.

This simple Ruby script will import HSBC bank statements and convert them into something which should be a little bit more readable.

==Dependencies==

===Ruby and RubyGems===

sudo aptitude install ruby rubygems ruby-dev

===Development packages===

sudo aptitude install build-essential libxml2-dev libxslt1-dev libopenssl-ruby

===Ruby libraries===

sudo gem install mechanize hpricot gchartrb markaby httparty stylish

sudo apt-get install libglib2.0-dev
sudo gem install rpeg-markdown 

==Usage==

===Filters===

The filters.yaml file contains a list of regular expressions which are run on the description of all imported transactions. If one of the regular expressions matches then it is placed in the specified category.