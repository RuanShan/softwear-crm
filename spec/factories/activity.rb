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
    #User relationship here!!!!
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

    factory :quote_activity_line_item do
      parameters(
        "groups" => [
          { 
            "group1" => {
              "imprintables" => {
                1 => {
                  "quantity" => 12,
                  "decoration_price" => 6.66,
                  "imprintable_price" => 3.33
                },
                2 => {
                  "quantity" => 1,
                  "decoration_price" => 1.00,
                  "imprintable_price" => 2.00
                }
              }, 
              "imprints" => { 
                1 => "1-blue",
                2 => "3-green" 
              }
            }
          },
          "group2" => {
            "imprintables" => {
              1 => {
                "quantity" => 100,
                "decoration_price" => 10.66,
                "imprintable_price" => 20.33
              },
              2 => {
                "quantity" => 45,
                "decoration_price" => 6.00,
                "imprintable_price" => 9.00
              }
            }, 
            "imprints" => { 
              1 => "5-red",
              2 => "7-yellow" 
            }
          }
        ]
      )
    end
  end
end
