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
* `has_many` - makes the possibility for one parent model to be associated with many instances of a child model. the `foreign_key` of the child model will match the `id` of the parent model.
* `has_one_through` - provides the functionality to create an association between two different models and an exisiting association. locates the associated object by going through two `belongs_to` methods.

### Using TableIt
If you would like to use TableIt with my `sample.rb` file or your own database please follow these steps.

#### Using TableIt With `sample.rb`
**1.** Clone the repo.
```
git clone https://github.com/ptascio/TableIt.git
```

**2.** CD into the repository. You are now in the root folder. Enter `pry` and then load `sample.rb`.
```
~/desktop/TableIt$ pry
[1]pry(main)> load 'sample.rb'
```

**3.** The sample seed data contains a table of Guitars, a table of the Musicians who play them, and a table of the Companies who sponsor the Musicians to ensure they keep using their instruments. You can use the methods listed above in `Functionality` to explore these relationships.

```` ruby

  #find the first guitar
  Guitar.first

  #find all the guitars for a specific musician
  Guitar.where(:musician_id => 3)

  #find all of the musicians
  Musician.all

  #find a specific company by id
  Company.find(1)

  #create a new Guitar entry
  Guitar.new(musician_id: 3, name: "Hagstrom III").save
````

#### Using TableIt With a Your Own Database
**1.** Clone the repo.
```
git clone https://github.com/ptascio/TableIt.git
```

**2.** CD into the repository. You are now in the root folder. Enter `pry` and then load `lib/db_connection.rb`.
```
~/desktop/TableIt$ pry
[1]pry(main)> load 'lib/db_connection.rb'
```

**3.** In order to use `DBConnection` you will need to know the full path of your `sql` file. If you don't know your file's full path simply copy your file into the root directory of TableIt.

```
[2]pry(main)> DBConnection.enter('path/to/your_sql_file.sql')
```

**4.** You will also want something analogous to my `sample.rb` in order to set up your classes and relationships. Please note it is **highly** recommended you store this file in the root directory because you will need to `require_relative lib/sql_object.rb` at the top of your file. Unlike `sample.rb` you will **not** need `DBConnection.reset` so omit that when you create your file.

##### A small snippet of what your file might look like:

```
require_relative 'lib/sql_object.rb'

class Book < SQLObject
	belongs_to(
		:author,
		class_name: "Author",
		foreign_key: :author_id,
		primary_key: :id
	)

	has_one_through(:publisher, :author, :publisher)
end

class Author < SQLObject
	has_many(
		:books,
		class_name: "Book",

```
etc.
