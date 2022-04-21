FactoryBot.define do
  factory :exam_master do
    transient do
      # answer_X_index is expected to be included in [1,2,3,4]
      # It does NOT mean Array index, which begins with 0
      answer_index { [1, 3] }
    end

    question { "ここに問題文が入ります。" }
    description { "ここに解説が入ります。" }

    trait :with_option_masters do
      after(:build) do |exam_master|
        exam_master.option_masters << build(:option_master, sentence: "ここに１つめの選択肢が入ります。")
        exam_master.option_masters << build(:option_master, sentence: "ここに２つめの選択肢が入ります。")
        exam_master.option_masters << build(:option_master, sentence: "ここに３つめの選択肢が入ります。")
        exam_master.option_masters << build(:option_master, sentence: "ここに４つめの選択肢が入ります。")
      end
    end

    after(:create) do |exam_master, evaluator|
      answer_index = evaluator.answer_index
      if answer_index.present?
        answer_index.each do |index|
          exam_master.__send__("answer_#{index}_id=", exam_master.option_masters[index - 1].id)
        end
        exam_master.save
      end
    end
  end
end
