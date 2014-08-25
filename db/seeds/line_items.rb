create_records([
  {
    name: 'HELLO',
    description: 'THIS IS NOT AN IMPRINTABLE',
    quantity: 1,
    unit_price: 2.20,
    line_itemable_id: 1,
    line_itemable_type: 'Job'
  },

  {
    name: "When's lunch?",
    description: "I'm hungry...",
    quantity: 2,
    unit_price: 0.5,
    line_itemable_id: 1,
    line_itemable_type: 'Job'
  },

  {
    name: 'Airplane food',
    description: "What's the deal with it, anyways",
    quantity: 3,
    unit_price: 5.12,
    line_itemable_id: 2,
    line_itemable_type: 'Job'
  },

  {
    name: "Can't wait",
    description: "To start on imprints",
    quantity: 3,
    unit_price: 12,
    taxable: true,
    line_itemable_id: 3,
    line_itemable_type: 'Job'
  },

  {
    name: 'What up',
    description: 'in this',
    quantity: 2,
    unit_price: 1,
    taxable: true,
    line_itemable_id: 3,
    line_itemable_type: 'Job'
  },

  {
    name: 'Unfortunate',
    description: "I don't really know what kind of stuff
                    would go here, so I just put all this
                    random garbage into the fields...",
    quantity: 1,
    unit_price: 100,
    line_itemable_id: 4,
    line_itemable_type: 'Job'
  },

  {
    name: 'Blah blah',
    description: 'Need more content!',
    quantity: 12,
    unit_price: 0.1,
    taxable: true,
    line_itemable_id: 4,
    line_itemable_type: 'Job'
  },

  {
    name: 'Wow',
    description: 'Do you know how many jobs are in these seeds?',
    quantity: 12,
    unit_price: 10,
    taxable: true,
    line_itemable_id: 5,
    line_itemable_type: 'Job'
  },

  {
    name: "It's dangerous to go alone",
    description: 'Take this',
    quantity: 1,
    unit_price: 99,
    taxable: true,
    line_itemable_id: 6,
    line_itemable_type: 'Job'
  },

  {
    name: 'Database entries',
    description: 'Mmmmmmmm',
    quantity: 9001,
    unit_price: 0.01,
    line_itemable_id: 7,
    line_itemable_type: 'Job'
  },

  {
    name: 'Stuff',
    description: '---',
    quantity: 0,
    unit_price: 10,
    line_itemable_id: 7,
    line_itemable_type: 'Job'
  },

  {
    name: 'Seeds, seeds',
    description: 'Hopefully worth the effort',
    quantity: 123,
    unit_price: 0.05,
    line_itemable_id: 8,
    line_itemable_type: 'Job'
  },

  {
    name: 'Hip threads',
    description: 'Those would probably be imprintable, though, hah',
    quantity: 2,
    unit_price: 10,
    taxable: true,
    line_itemable_id: 9,
    line_itemable_type: 'Job'
  },

  {
    name: 'Maybe',
    description: 'I do know what kind of stuff would go here',
    quantity: 1,
    unit_price: 0,
    line_itemable_id: 9,
    line_itemable_type: 'Job'
  },

  {
    name: 'More stuff',
    description: '----------',
    quantity: 16,
    unit_price: 20,
    line_itemable_id: 10,
    line_itemable_type: 'Job'
  },

  {
    name: '----',
    description: 'Where exactly do you buy this?',
    quantity: 12,
    unit_price: 12,
    line_itemable_id: 11,
    line_itemable_type: 'Job'
  },

  {
    name: 'Why are your hands so cold?',
    description: 'That me hook.',
    quantity: 1,
    unit_price: 100,
    line_itemable_id: 11,
    line_itemable_type: 'Job'
  },

  {
    name: 'db:seed last ran on: ',
    description: Time.now.to_s,
    quantity: 1,
    unit_price: 20,
    line_itemable_id: 12,
    line_itemable_type: 'Job'
  },

  {
    name: 'Blah',
    description: '-',
    quantity: 1,
    unit_price: 100,
    line_itemable_id: 12,
    line_itemable_type: 'Job'
  }
  
  ], LineItem)

create_imprintable_line_items 3, 4, line_itemable_id: 1, line_itemable_type: 'Job',
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}
create_imprintable_line_items 2, 4, line_itemable_id: 1, line_itemable_type: 'Job'

create_imprintable_line_items 3, 4, line_itemable_id: 2, line_itemable_type: 'Job'
create_imprintable_line_items 2, 4, line_itemable_id: 2, line_itemable_type: 'Job',
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}
create_imprintable_line_items 2, 2, line_itemable_id: 2, line_itemable_type: 'Job',
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}

create_imprintable_line_items 1, 1, line_itemable_id: 4, line_itemable_type: 'Job'
create_imprintable_line_items 2, 2, line_itemable_id: 4, line_itemable_type: 'Job',
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}

create_imprintable_line_items 2, 1, line_itemable_id: 5, line_itemable_type: 'Job'
create_imprintable_line_items 2, 3, line_itemable_id: 5, line_itemable_type: 'Job'

create_imprintable_line_items 3, 1, line_itemable_id: 6, line_itemable_type: 'Job'
create_imprintable_line_items 3, 3, line_itemable_id: 6, line_itemable_type: 'Job'

create_imprintable_line_items 1, 3, line_itemable_id: 7, line_itemable_type: 'Job'
create_imprintable_line_items 2, 3, line_itemable_id: 7, line_itemable_type: 'Job'
create_imprintable_line_items 3, 3, line_itemable_id: 7, line_itemable_type: 'Job'

create_imprintable_line_items 1, 4, line_itemable_id: 8, line_itemable_type: 'Job',
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}

create_imprintable_line_items 3, 4, line_itemable_id: 9, line_itemable_type: 'Job'

create_imprintable_line_items 3, 1, line_itemable_id: 10, line_itemable_type: 'Job'
create_imprintable_line_items 3, 2, line_itemable_id: 10, line_itemable_type: 'Job'

create_imprintable_line_items 1, 4, line_itemable_id: 11, line_itemable_type: 'Job',
                after: -> (r) {r.unit_price = 12.50; r.quantity = [1,2,3].sample}

create_imprintable_line_items 2, 2, line_itemable_id: 12, line_itemable_type: 'Job'
