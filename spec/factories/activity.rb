FactoryGirl.define do
  factory :proof_activity, class: PublicActivity::Activity do
    trackable { |t| t.association(:valid_proof) }
    after(:create) do |activity|
      activity.recipient = activity.trackable.order
    end
  end
  
  factory :quote_activity, class: PublicActivity::Activity do

    trackable { |q| q.association(:valid_quote) }
    association :owner, factory: :user
    factory :quote_activity_update do
      parameters(
          "first_name" => {
            "old" => "Bob",
            "new" => "Jim"
          },
          "is_rushed" => {
            "old" => false,
            "new" => true
          }
        )
    end

    factory :quote_activity_add_imprintable do
      parameters(
      'imprintables' => {
        1 =>  {
            "imprintable_id" => 1,
            "imprintable_price" => 0.70, 
            "group_id" => 1, #group_id
            "tier" => 3,
            "quantity" => 100,
            "decoration_price" => 1.50
          },
        2 =>  {
            "imprintable_id" => 4,
            "imprintable_price" => 0.90, 
            "group_id" => 3, #group_id
            "tier" => 1,
            "quantity" => 130,
            "decoration_price" => 1.33
          }
        }
      )
    end

    factory :quote_activity_markup do
      parameters(
        "name" => "Mo Money",
        "description" => "Mo Problems",
        "url" => "www.money.com",
        "unit_price" => 664
      )
    end

    factory :quote_activity_note do
      parameters(
        "title" => "Hello",
        "comment" => "This is note"
      )
    end

    factory :quote_activity_line_item_update do
      parameters(
        "group_id" => 1,  
        "imprintables" => {
            1 => {
              "quantity" => {"old" => 12, "new" => 40},
              "decoration_price" => {"old" => 5.00, "new" => 10.00},
              "imprintable_price" => {"old" => 8.00, "new" => 18.00}
            },
            2 => {
              "quantity" => {"old" => 22, "new" => 30},
              "decoration_price" => {"old" => 4.00, "new" => 17.00},
              "imprintable_price" => {"old" => 4.00, "new" => 58.00}
            }
          }, 
          "imprints" => {
            1 => {
              "old" => {
                "description" => "1-blue",
                "imprint_location_id" => 1
              }, 
              "new" => {
                "description" => "14-orange",
                "imprint_location_id" => 2
              }
            },
            2 => {
              "old" => {
                "description" => "4-green",
                "imprint_location_id" => 3
              }, 
              "new" => {
                "description" => "3-red",
                "imprint_location_id" => 4
              }
            }
          }
      )
    end
    
    # quote_activity_line_item_group
    factory :quote_activity_line_item_group do
      parameters(
          "imprintables" => {
            1 => 0.10,
            2 => 0.50
          }, 
          "imprints" => { 
            1 => "1-blue",
            2 => "3-green" 
          },
          "name" => "group1",
          "ID" => 1, #group id aka job id
          "quantity" => 100,
          "decoration_price" => 1.50
      )
    end
  end
end
