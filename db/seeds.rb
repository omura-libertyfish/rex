require 'securerandom'

question = <<-'QUES'
（１）に入るメソッドを以下の選択肢から選んでください
```ruby
class Fizz
def initialize
puts "hello, world"
end
end

class Buzz < Fizz
def initialize
(1)
end
end
```
QUES

description = <<-'DESC'
ここに解説が入ります。ここに解説が入ります。ここに解説が入ります。
```ruby
# プログラムがかけます。
p @hello_world #=> nil
```
DESC

sentence = <<-'SENT'
```ruby
  super
```
SENT

ActiveRecord::Base.transaction do
  gold_count = 0
  silver_count = 0
  500.times do |index|
    category = 0
    exam_type = index.even? ? :gold : :silver
    if exam_type == :gold
      # goldはenum categoryを0〜5で設定しているため6で剰余算。
      category = gold_count % 6
      gold_count += 1
    else
      # silverはenum categoryを1〜3で設定しているため剰余算後1を加算。
      category = silver_count % 3 + 1
      silver_count += 1
    end
    exam_master = ExamMaster.new(master_uuid: SecureRandom.uuid, question: question, description: description, exam_type: exam_type, category: category)

    exam_master.option_masters << OptionMaster.create(sentence: sentence)
    exam_master.option_masters << OptionMaster.create(sentence: sentence)
    exam_master.option_masters << OptionMaster.create(sentence: sentence)
    exam_master.option_masters << OptionMaster.create(sentence: sentence)

    option = exam_master.option_masters.first
    exam_master.answer_1_id = option.id

    exam_master.save!
  end
end
