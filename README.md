## TableIt

TableIt is a library inspired by Ruby on Rails' own ActiveRecord library. This library provides the necessary functionality between a Rails' **Model** class and an existing database. Models can also be connected to one another via **associations**.  

### Functionality
TableIt provides these key functions for necessary querying and model associations:

#### Search

* `all` - returns an array of hashes of all instances of the particular model.
* `find(id)` - returns the object which matches the queried id.
* `initialize(params)` - instantiates an object using the passed in params.
* `insert` - queries the database for the necessary and provides an id to the insertion.
* `update` - queries the database for the necessary column(s) and updates the data associated with particular column(s).
* `save` - returns insert or update based on whether an instance of the object already exists in the database.
* `where(params)` - returns an instance or instances of the class which match params passed in.

#### Associations

* `belongs_to` - creates functionality for one model to be associated to another through a `foreign_key` which will match the `id` of the parent model being associated to it.
* `has_many` - makes the possibility for one parent model to be associated with many instances of a child model. the `foreign_key` of the child model will matcht the `id` of the parent model.
* `has_one_through` - provides the functionality to create an association between two different models and an exisiting association. locates the associated object by going through two `belongs_to` methods.

```ruby
def self.find(id)
     this_query = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
     SQL
     return nil if this_query.empty?
     self.new(this_query.first)
  end


  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      primary_key = self.send(options.primary_key)
      model_class = options.model_class
      model = model_class.where(options.foreign_key => primary_key)
    end
  end
  ```
