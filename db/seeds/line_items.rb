create_records([
  {name: 'HELLO', description: 'THIS IS NOT AN IMPRINTABLE', 
    quantity: 1, unit_price: 2.20, job_id: 1},
  {name: "When's lunch?", description: "I'm hungry...",
    quantity: 2, unit_price: 0.5, job_id: 1},

  {name: 'Airplane food', description: "What's up with it, anyways?!",
    quantity: 3, unit_price: 5.12, job_id: 2},

  {name: "Can't wait", description: "To start on imprints",
    quantity: 3, unit_price: 12, taxable: true, job_id: 3},
  {name: 'What up', description: 'in this',
    quantity: 2, unit_price: 1, taxable: true, job_id: 3},

  {name: "Unfortunate", description: "I don't really know what kind of stuff
                                      would go here, so I just put all this 
                                      random garbage into the fields...",
    quantity: 1, unit_price: 100, job_id: 4},
  {name: "Blah blah", description: "Need more content!",
    quantity: 12, unit_price: 0.1, taxable: true, job_id: 4},

  {name: "Wow", description: "Do you know how many jobs are in these seeds?",
    quantity: 12, unit_price: 10, taxable: true, job_id: 5},

  {name: "It's dangerous to go along", description: "Take this!",
    quantity: 1, unit_price: 99, taxable: true, job_id: 6},

  {name: "Database entries", description: "Mmmmmmmm",
    quantity: 9001, unit_price: 0.01, job_id: 7},
  {name: "Apology", description: '---',
    quantity: 0, unit_price: 10, job_id: 7},

  {name: "Seeds, seeds", description: "Hopefully worth the effort",
    quantity: 123, unit_price: 0.05, job_id: 8},

  {name: "Hip threads", description: "Those would probably be imprintable, though",
    quantity: 2, unit_price: 10, taxable: true, job_id: 9},
  {name: "Precious Ruby", description: "What could this possibly have to do with 
    printing t-shirts?", quantity: 1, unit_price: 0, job_id: 9},

  {name: "Megapixel", description: "hah", quantity: 16,
    unit_price: 20, job_id: 10},

  {name: "Excellence", description: 'Where exactly do you buy this?',
    quantity: 12, unit_price: 12, job_id: 11},
  {name: "Why are your hands so cold?", description: "That me hook.",
    quantity: 1, unit_price: 100, job_id: 11},

  {name: "db:seed last ran on: ", description: Time.now.to_s,
    quantity: 1, unit_price: 20, job_id: 12},
  {name: "A job well done", description: '-',
    quantity: 1, unit_price: 100, job_id: 12}
  
  ], LineItem)

create_imprintable_line_items 3, 4, job_id: 1,
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}
create_imprintable_line_items 2, 4, job_id: 1

create_imprintable_line_items 3, 4, job_id: 2
create_imprintable_line_items 2, 4, job_id: 2,
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}
create_imprintable_line_items 2, 2, job_id: 2,
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}

create_imprintable_line_items 1, 1, job_id: 4
create_imprintable_line_items 2, 2, job_id: 4,
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}

create_imprintable_line_items 2, 1, job_id: 5
create_imprintable_line_items 2, 3, job_id: 5

create_imprintable_line_items 3, 1, job_id: 6
create_imprintable_line_items 3, 3, job_id: 6

create_imprintable_line_items 1, 3, job_id: 7
create_imprintable_line_items 2, 3, job_id: 7
create_imprintable_line_items 3, 3, job_id: 7

create_imprintable_line_items 1, 4, job_id: 8,
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}

create_imprintable_line_items 3, 4, job_id: 9

create_imprintable_line_items 3, 1, job_id: 10
create_imprintable_line_items 3, 2, job_id: 10

create_imprintable_line_items 1, 4, job_id: 11,
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}

create_imprintable_line_items 2, 2, job_id: 12
