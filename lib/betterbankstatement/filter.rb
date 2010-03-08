
module BetterBankStatement
  class Filter
    include DataMapper::Resource
    property :id, Serial
    property :expression, String
    belongs_to :category

    def self.import(filename)
      YAML.load_file(filename).each { |filter|
        category = Category.create_or_get(:name => filter[:category])
        filter= Filter.new(:expression => filter[:expression], 
                   :category => category)
        filter.save
      }
    end

    # Required for serialization
    def category_name
      category.name
    end
  end
end
