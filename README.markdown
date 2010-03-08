<!-- -*- mode: markdown; -*- -->

# Better Bank Statement

Owen Griffin, 2009.

This simple Ruby script will import bank statements and convert them into web site complete with graphs and categorizations.

BetterBankStatement does not access your bank account directly - it reads all of it's information required from your saved bank statemenents.

By using this application you must accept that you are entirely liable for the security of it's results and of your information. 

## Dependencies

This program would not be possible without various freely available utilities. The following list of dependencies is based on packages with the Ubuntu Linux distribution.

### Ruby and RubyGems

    sudo aptitude install ruby rubygems ruby-dev

#### Development packages

    sudo aptitude install build-essential libxml2-dev libxslt1-dev libopenssl-ruby

#### Ruby libraries

    sudo gem install mechanize hpricot gchartrb markaby httparty stylish

    sudo apt-get install libglib2.0-dev
    sudo gem install rpeg-markdown 

## Getting Started

Once you have installed all the dependencies you should be able to run BetterBankStatement. 

### Account export

BetterBankStatement imports information in different formats; CSV, QIF and PDF. Currently it only supports information from HSBC.

You should be able to export this information from your online banking facility. You should place this information on a folder on your machine. This folder will be read by BetterBankStatement.

### PDF

BetterBankStatement does not directly read PDF files. You will need to convert them into text files first. To do this run the following command:

    pdftotext -l *.pdf

### Generating the statement

BetterBankStatement can by run using the following command:

    ./betterbankstatement.rb data/

Where _data/_ is the folder which contains all your exported statements.

## Misc

### Graphs

The graphs on BetterBankStatement use the OpenFlashChart component. For these to work you will need to host your statement on a web server. It wouldn't be a good idea to host this on the internet.

### Filters

The filters.yaml file contains a list of regular expressions which are run on the description of all imported transactions. If one of the regular expressions matches then it is placed in the specified category.

## Development

### Tests

#### Individual tests

    cucumber -v features/site/category_list.feature -r features/support/env.rb -r features/step_definitions/
