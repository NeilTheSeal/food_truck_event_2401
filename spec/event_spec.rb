require "./spec/spec_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe Event do
  before(:each) do
    @event = Event.new("South Pearl Street Farmers Market")

    @food_truck1 = FoodTruck.new("Rocky Mountain Pies")
    @food_truck2 = FoodTruck.new("Ba-Nom-a-Nom")
    @food_truck3 = FoodTruck.new("Palisade Peach Shack")

    @item1 = Item.new({ name: "Peach Pie (Slice)", price: "$3.75" })
    @item2 = Item.new({ name: "Apple Pie (Slice)", price: "$2.50" })
    @item3 = Item.new({ name: "Peach-Raspberry Nice Cream", price: "$5.30" })
    @item4 = Item.new({ name: "Banana Nice Cream", price: "$4.25" })

    @food_truck1.stock(@item1, 35)
    @food_truck1.stock(@item2, 7)
    @food_truck2.stock(@item4, 50)
    @food_truck2.stock(@item3, 25)
    @food_truck3.stock(@item1, 65)
  end

  describe "#initialize" do
    it "exists" do
      expect(@event).to be_an_instance_of(Event)
    end

    it "has attributes" do
      expect(@event.name).to eq("South Pearl Street Farmers Market")
      expect(@event.food_trucks).to eq([])
    end
  end

  describe "#food trucks" do
    before(:each) do
      @event.add_food_truck(@food_truck1)
      @event.add_food_truck(@food_truck2)
      @event.add_food_truck(@food_truck3)
    end

    it "can add food trucks" do
      expect(@event.food_trucks).to eq([
        @food_truck1, @food_truck2, @food_truck3
      ])
    end

    it "can list food truck names" do
      expect(@event.food_truck_names).to eq([
        "Rocky Mountain Pies", "Ba-Nom-a-Nom", "Palisade Peach Shack"
      ])
    end

    it "can list the food trucks that sell an item" do
      expect(@event.food_trucks_that_sell(@item1)).to eq([
        @food_truck1, @food_truck3
      ])
      expect(@event.food_trucks_that_sell(@item4)).to eq([@food_truck2])
    end
  end

  describe "#items" do
    before(:each) do
      @event.add_food_truck(@food_truck1)
      @event.add_food_truck(@food_truck2)
      @event.add_food_truck(@food_truck3)
    end

    it "can provide a sorted item list" do
      expect(@event.sorted_item_list).to eq([
        "Apple Pie (Slice)",
        "Banana Nice Cream",
        "Peach Pie (Slice)",
        "Peach-Raspberry Nice Cream"
      ])
    end

    it "can list total inventory" do
      expect(@event.total_inventory).to eq({
        @item1 => {
          quantity: 100,
          food_trucks: [@food_truck1, @food_truck3]
        },
        @item2 => {
          quantity: 7,
          food_trucks: [@food_truck1]
        },
        @item3 => {
          quantity: 25,
          food_trucks: [@food_truck2]
        },
        @item4 => {
          quantity: 50,
          food_trucks: [@food_truck2]
        }
      })
    end

    it "can list overstocked items" do
      expect(@event.overstock_items).to eq([@item1])

      @food_truck1.stock(@item3, 30)

      expect(@event.overstock_items).to eq([@item1, @item3])

      @food_truck2.stock(@item4, 20)

      expect(@event.overstock_items).to eq([@item1, @item3])
    end
  end

  describe "#sales at an event" do
    before(:each) do
      @event.add_food_truck(@food_truck1)
      @event.add_food_truck(@food_truck2)
      @event.add_food_truck(@food_truck3)
    end

    it "can provide a date" do
      past_date = Date.new(2005, 1, 5).strftime("%d/%m/%Y")
      allow(@event).to receive(:date).and_return(past_date)
      expect(@event.date).to eq("05/01/2005")
    end

    it "can sell items" do
      is_sold = @event.sell(@item1, 5)
      expect(@food_truck1.check_stock(@item1)).to eq(30)
      expect(@food_truck3.check_stock(@item1)).to eq(65)
      expect(is_sold).to eq(true)

      is_sold = @event.sell(@item1, 35)
      expect(@food_truck1.check_stock(@item1)).to eq(0)
      expect(@food_truck3.check_stock(@item1)).to eq(60)
      expect(is_sold).to eq(true)

      is_sold = @event.sell(@item1, 65)
      expect(@food_truck3.check_stock(@item1)).to eq(60)
      expect(is_sold).to eq(false)
    end
  end
end
# rubocop:enable Metrics/BlockLength
