require 'spec_helper'
require "#{Rails.root.join('lib/tasks/deploy')}"

describe Deploy do

  describe Deploy::AbstractTable do
    let(:table) { Deploy::AbstractTable.new('master_uuid', 'exam_masters', 'question', 'description') }
    let(:child_table) { Deploy::AbstractTable.new('id', 'option_masters', 'sentence') }

    describe '#instantize' do
      it 'builds a object of ExamMaster' do
        expect(table.instantize).to be_a(ExamMaster)
      end
    end

    describe '#find' do
      let(:uuid) { SecureRandom.uuid }
      let(:fake_uuid) { SecureRandom.uuid }

      before do
        create(:exam_master, :with_option_masters, master_uuid: uuid)
      end

      context 'when find by fake uuid' do
        it "must not exist with finding by fake uuid" do
          expect(table.find(fake_uuid)).to eq(nil)
        end
      end

      context 'when find by uuid' do
        it "must exist with finding by uuid" do
          expect(table.find(uuid).master_uuid).to eq(uuid)
        end
      end

      context 'when relation is build' do
        before do
          table.has_many(child_table, 4)
          allow(ExamMaster).to receive_message_chain(:includes).with('option_masters').and_call_original
        end

        it 'includes related table' do
          expect(table.find(uuid).master_uuid).to eq(uuid)
        end
      end
    end

    describe '#find_or_instantize' do
      let(:uuid) { SecureRandom.uuid }

      subject { table.find_or_instantize(uuid) }

      context 'if record has not saved yet' do
        it '#new_record? must be truthy' do
          expect(subject.new_record?).to be_truthy
        end
      end

      context 'if record has already saved' do
        before do
          create(:exam_master, :with_option_masters, master_uuid: uuid)
        end

        it '#persisted? must be truthy' do
          expect(subject.persisted?).to be_truthy
        end
      end
    end

    describe '#has_many' do
      it 'assigns a object of Deploy::AbstractRelation' do
        expect{ table.has_many(child_table, 4) }.to change{ table.relation }.from(NilClass).to(Deploy::AbstractRelation)
      end
    end

    describe '#attr_template' do
      it 'assigns new object id (checking immutability)' do
        expect(table.instance_variable_get(:@attr_template).__id__).not_to eq(table.attr_template.__id__)
      end
    end

    describe '#assign_attributes' do
      let(:expect_attributes) {
        {
          question: 'ここに問題文が入ります。',
          description: 'ここに解説が入ります。',
          option_masters_attributes: [
            { sentence: 'ここに１つめの選択肢が入ります。' },
            { sentence: 'ここに２つめの選択肢が入ります。' },
            { sentence: 'ここに３つめの選択肢が入ります。' },
            { sentence: 'ここに４つめの選択肢が入ります。' }
          ]
        }
      }

      let(:table_attribute) {
        {
          question: 'ここに問題文が入ります。',
          description: 'ここに解説が入ります。'
        }
      }

      let(:relation_attribute) {
        [
          { sentence: 'ここに１つめの選択肢が入ります。' },
          { sentence: 'ここに２つめの選択肢が入ります。' },
          { sentence: 'ここに３つめの選択肢が入ります。' },
          { sentence: 'ここに４つめの選択肢が入ります。' }
        ]
      }

      before do
        table.has_many(child_table, 4)
      end

      it 'converts hash syntax for ActiveRecord' do
        expect(table.assign_attributes(table_attribute, relation_attribute)).to include(expect_attributes)
      end
    end

    describe '#relation_assign_attributes' do
      context 'if no relation has been built' do
        it 'expects blank hash' do
          expect(table.relation_assign_attributes(table).size).to eq(0)
        end
      end

      context 'if relation has been built' do
        before do
          table.has_many(child_table, 4)
        end

        subject { table.relation_assign_attributes(relation_attr) }

        context 'and built attributes for saving new record' do
          let(:relation_attr) {
            [
              {sentence: 'ここに１つめの選択肢が入ります。'},
              {sentence: 'ここに２つめの選択肢が入ります。'},
              {sentence: 'ここに３つめの選択肢が入ります。'},
              {sentence: 'ここに４つめの選択肢が入ります。'}
            ]
          }

          let(:expect_attributes) {
            {
              option_masters_attributes: [
                {sentence: 'ここに１つめの選択肢が入ります。'},
                {sentence: 'ここに２つめの選択肢が入ります。'},
                {sentence: 'ここに３つめの選択肢が入ります。'},
                {sentence: 'ここに４つめの選択肢が入ります。'}
              ]
            }
          }

          it 'builds formatted association for sentence' do
            expect(subject).to include(expect_attributes)
          end
        end

        context 'and built attributes for updating record' do
          let(:relation_attr) {
            [
              {id: exam_master.option_masters[0].id, sentence: 'ここに１つめの選択肢が入ります。'},
              {id: exam_master.option_masters[1].id, sentence: 'ここに２つめの選択肢が入ります。'},
              {id: exam_master.option_masters[2].id, sentence: 'ここに３つめの選択肢が入ります。'},
              {id: exam_master.option_masters[3].id, sentence: 'ここに４つめの選択肢が入ります。'}
            ]
          }

          let(:expect_attributes) {
            {
              option_masters_attributes: [
                {id: exam_master.option_masters[0].id, sentence: 'ここに１つめの選択肢が入ります。'},
                {id: exam_master.option_masters[1].id, sentence: 'ここに２つめの選択肢が入ります。'},
                {id: exam_master.option_masters[2].id, sentence: 'ここに３つめの選択肢が入ります。'},
                {id: exam_master.option_masters[3].id, sentence: 'ここに４つめの選択肢が入ります。'}
              ]
            }
          }

          let(:exam_master) { create(:exam_master, :with_option_masters) }

          it 'builds formatted association for sentence and id' do
            expect(subject).to include(expect_attributes)
          end
        end
      end
    end

    describe '#relation_limit' do
      context 'if no relation built' do
        it 'returns nil (it means no relation)' do
          expect(table.relation_limit).to eq(nil)
        end
      end

      context 'if relation built' do
        before do
          table.has_many(child_table, 4)
        end

        it 'returns the upper limit on has many relation' do
          expect(table.relation_limit).to eq(4)
        end
      end
    end

    describe '#relation_name' do
      context 'if no relation built' do
        it 'returns nil (it means no relation)' do
          expect(table.relation_name).to eq(nil)
        end
      end

      context 'if relation built' do
        before do
          table.has_many(child_table, 4)
        end

        it 'returns relation table name' do
          expect(table.relation_name).to eq('option_masters')
        end
      end
    end

    describe '#primary_key' do
      it 'returns a primary key' do
        expect(table.primary_key).to eq('master_uuid')
      end
    end

    describe '#table_name' do
      it 'returns a table name' do
        expect(table.table_name).to eq('exam_masters')
      end
    end

    describe '#columns' do
      it 'returns a column names' do
        expect(table.columns).to match_array(['question', 'description'])
      end
    end
  end

  describe Deploy::AbstractRelation do
    let(:table) { Deploy::AbstractTable.new('master_uuid', 'exam_masters', 'question', 'description') }
    let(:child_table) { Deploy::AbstractTable.new('id', 'option_masters', 'sentence') }

    subject { table.has_many(child_table, 4) }

    describe '#primary_key' do
      it 'responds to #id' do
        expect(subject.primary_key).to eq('id')
      end
    end

    describe '#table_name' do
      it 'responds to #table_name' do
        expect(subject.table_name).to eq('option_masters')
      end
    end

    describe '#columns' do
      it 'responds to #columns' do
        expect(subject.columns).to match_array(['sentence'])
      end
    end

    describe '#assign_attributes' do
      let(:relation_attributes) {
        [
          { sentence: "ここに１つめの選択肢が入ります。" },
          { sentence: "ここに２つめの選択肢が入ります。" },
          { sentence: "ここに３つめの選択肢が入ります。" },
          { sentence: "ここに４つめの選択肢が入ります。" }
        ]
      }

      let(:expect_attributes) {
        {
          option_masters_attributes: [
            { sentence: "ここに１つめの選択肢が入ります。" },
            { sentence: "ここに２つめの選択肢が入ります。" },
            { sentence: "ここに３つめの選択肢が入ります。" },
            { sentence: "ここに４つめの選択肢が入ります。" }
          ]
        }
      }

      it 'converts hash syntax for ActiveRecord' do
        expect(subject.assign_attributes(relation_attributes)).to include(expect_attributes)
      end
    end
  end

  describe '::markdown_files' do
    let(:markdown_files) {
      %w( exam_masters_question.md
          exam_masters_description.md
          option_masters_sentence_1.md
          option_masters_sentence_2.md
          option_masters_sentence_3.md
          option_masters_sentence_4.md
        )
    }

    let(:relation) {
      {
        table: {
          name: 'exam_masters',
          columns: [
            'question',
            'description'
          ],
          primary_key: 'master_uuid'
        },
        has_many: {
          table: {
            name: 'option_masters',
            columns: [
              'sentence'
            ],
            primary_key: 'id'
          },
          limit: 4
        }
      }.with_indifferent_access
    }

    it 'returns an array which contains of markdown files' do
      expect(Deploy::markdown_files(relation)).to match_array(markdown_files)
    end
  end

  describe '::execute' do

    subject { Deploy::execute(uuids, relation) }

    let(:uuids) {
      [Rails.root.join('spec/repos/' + uuid)]
    }

    let(:uuid) {
      'gold0001-8cd1-41d4-9ec7-e2c331f6c7bc'
    }

    let(:relation) {
      {
        table: {
          name: 'exam_masters',
          columns: [
            'question',
            'description'
          ],
          primary_key: 'master_uuid'
        },
        has_many: {
          table: {
            name: 'option_masters',
            columns: [
              'sentence'
            ],
            primary_key: 'id'
          },
          limit: 4
        }
      }.with_indifferent_access
    }

    let(:exam_master) {
      ExamMaster.find_by(master_uuid: uuid)
    }

    let(:sentences) {
      [
        "選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。\nこの選択肢は１番目です。\n",
        "選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。\nこの選択肢は２番目です。\n",
        "選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。\nこの選択肢は３番目です。\n",
        "選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。\nこの選択肢は４番目です。\n",
      ]
    }

    context 'when exam has already saved' do
      before do
        create(:exam_master, :with_option_masters, master_uuid: uuid)
      end

      it "doesn't increase a count of ExamMaster" do
        expect{ subject }.to_not change(ExamMaster, :count)
      end

      it "updates the value of question" do
        expect{ subject }.to change{ ExamMaster.find_by(master_uuid: uuid).question }.to(<<-QUESTION)
ここが問題文です。ここが問題文です。ここが問題文です。ここが問題文です。ここが問題文です。
この問題は読み込まれます。この問題は読み込まれます。この問題は読み込まれます。

```ruby
class Bazz
  attr_accessor :hoge

  def hello_world
    puts "hello, world"
  end
end
```
        QUESTION
      end

      it "updates the value of description" do
        expect{ subject }.to change{ ExamMaster.find_by(master_uuid: uuid).description }.to(<<-DESCRIPTION)
ここに解説が入ります。ここに解説が入ります。ここに解説が入ります。ここに解説が入ります。
この問題は読み込まれます。この問題は読み込まれます。この問題は読み込まれます。

```ruby
class Bazz
  attr_accessor :hoge

  def hello_world
    puts "hello, world"
  end
end
```
        DESCRIPTION
      end

      [*0..3].each do |index|
        it 'expects to update each sentence' do
          expect{ subject }.to change{ ExamMaster.find_by(master_uuid: uuid).option_masters[index].sentence }.to(sentences[index])
        end
      end
    end

    context 'if any records have not saved yet' do
      it 'increases a count of ExamMaster' do
        expect{ subject }.to change{ ExamMaster.count }.from(0).to(1)
      end
    end

    context 'after loading default.yml' do
      before do
        subject
      end

      context 'whose exam type is gold' do
        it 'expects exam type is gold' do
          expect(exam_master.gold?).to be_truthy
        end
      end

      context 'whose exam type is silver' do
        let(:uuid) {
          'silver01-8cd1-41d4-9ec7-e2c331f6c7bc'
        }

        it 'expects exam type is silver' do
          expect(exam_master.silver?).to be_truthy
        end
      end

      it 'expects answer_X_id is correctly setted' do
        expect(exam_master.answer_ids).to match_array([exam_master.option_masters[1].id, exam_master.option_masters[2].id])
      end
    end

    context 'after loading Markdown' do
      before do
        subject
      end

      it 'inserts question to its cloumn' do
        expect(exam_master.question).to eq(<<-QUESTION)
ここが問題文です。ここが問題文です。ここが問題文です。ここが問題文です。ここが問題文です。
この問題は読み込まれます。この問題は読み込まれます。この問題は読み込まれます。

```ruby
class Bazz
  attr_accessor :hoge

  def hello_world
    puts "hello, world"
  end
end
```
        QUESTION
      end

      it 'inserts description to its cloumn' do
        expect(exam_master.description).to eq(<<-DESCRIPTION)
ここに解説が入ります。ここに解説が入ります。ここに解説が入ります。ここに解説が入ります。
この問題は読み込まれます。この問題は読み込まれます。この問題は読み込まれます。

```ruby
class Bazz
  attr_accessor :hoge

  def hello_world
    puts "hello, world"
  end
end
```
        DESCRIPTION
      end

      [*0..3].each do |index|
        it 'expects to insert each sentence' do
          expect(exam_master.option_masters[index].sentence).to eq(sentences[index])
        end
      end
    end
  end

  describe '::build_table' do

    subject { Deploy::build_table(relation) }

    context 'only one table' do
      let(:relation) {
        {
          table: {
            name: 'exam_masters',
            columns: [
              'question',
              'description'
            ],
            primary_key: 'master_uuid'
          }
        }.with_indifferent_access
      }

      it 'builds an object of Deploy::AbstractTable' do
        expect(subject).to be_a(Deploy::AbstractTable)
      end
    end

    context 'plural relation' do
      let(:relation) {
        {
          table: {
            name: 'exam_masters',
            columns: [
              'question',
              'description'
            ],
            primary_key: 'master_uuid'
          },
          has_many: {
            table: {
              name: 'option_masters',
              columns: [
                'sentence'
              ],
              primary_key: 'id'
            },
            limit: 4
          }
        }.with_indifferent_access
      }

      it 'builds an object of Deploy::AbstractTable which has relation for "option_masters"' do
        expect(subject.relation_name).to eq('option_masters')
        expect(subject.relation_limit).to eq(4)
      end
    end
  end

  describe '::table_to_markdown' do
    let(:exam_master) { Deploy::AbstractTable.new('master_uuid', 'exam_masters', 'question', 'description') }
    let(:option_master) { Deploy::AbstractTable.new('id', 'option_masters', 'sentence') }

    context 'when exam_master is passed' do
      let(:markdown_files) {
        {
          'exam_masters_description.md' => {:table => 'exam_masters', :column => 'description'},
          'exam_masters_question.md' => {:table => 'exam_masters', :column => 'question'}
        }
      }
      subject { Deploy::table_to_markdown(exam_master) }
      it { is_expected.to include(markdown_files) }
    end

    context 'when option_master is passed' do
      let(:markdown_files) {
        {
          'option_masters_sentence.md' => {:table => 'option_masters', :column => 'sentence'}
        }
      }
      subject { Deploy::table_to_markdown(option_master) }
      it { is_expected.to include(markdown_files) }
    end
  end

  describe '::relation_to_markdown' do
    let(:exam_master) { Deploy::AbstractTable.new('master_uuid', 'exam_masters', 'question', 'description') }
    let(:option_master) { Deploy::AbstractTable.new('id', 'option_masters', 'sentence') }

    context 'ExamMaster has relation to OptionMaster' do
      let(:markdown_files) {
        {
          'option_masters_sentence_1.md' => {table: 'option_masters', column: 'sentence', index: 1},
          'option_masters_sentence_2.md' => {table: 'option_masters', column: 'sentence', index: 2}
        }
      }

      before do
        exam_master.has_many(option_master, 2)
      end

      it 'builds expect a hash syntax' do
        expect(Deploy::relation_to_markdown(exam_master)).to include(markdown_files)
      end
    end

    context 'OptionMaster has relation to ExamMaster' do
      let(:markdown_files) {
        {
          'exam_masters_question_1.md' => {table: 'exam_masters', column: 'question', index: 1},
          'exam_masters_question_2.md' => {table: 'exam_masters', column: 'question', index: 2},
          'exam_masters_question_3.md' => {table: 'exam_masters', column: 'question', index: 3},
          'exam_masters_question_4.md' => {table: 'exam_masters', column: 'question', index: 4},
          'exam_masters_description_1.md' => {table: 'exam_masters', column: 'description', index: 1},
          'exam_masters_description_2.md' => {table: 'exam_masters', column: 'description', index: 2},
          'exam_masters_description_3.md' => {table: 'exam_masters', column: 'description', index: 3},
          'exam_masters_description_4.md' => {table: 'exam_masters', column: 'description', index: 4}
        }
      }

      before do
        option_master.has_many(exam_master, 4)
      end

      it 'builds expect a hash syntax' do
        expect(Deploy::relation_to_markdown(option_master)).to include(markdown_files)
      end
    end
  end

  describe '::table_to_attributes' do
    let(:uuid) {
      Rails.root.join('spec/repos/gold0001-8cd1-41d4-9ec7-e2c331f6c7bc')
    }

    let(:table) { Deploy::AbstractTable.new('master_uuid', 'exam_masters', 'question') }

    let(:expect_attributes) {
      {
        'question' => question
      }
    }

    let(:question) {
      <<-QUESTION
ここが問題文です。ここが問題文です。ここが問題文です。ここが問題文です。ここが問題文です。
この問題は読み込まれます。この問題は読み込まれます。この問題は読み込まれます。

```ruby
class Bazz
  attr_accessor :hoge

  def hello_world
    puts "hello, world"
  end
end
```
      QUESTION
    }

    it 'expect to read markdown about question' do
      expect(Deploy::table_to_attributes(uuid, table)).to include(expect_attributes)
    end
  end

  describe '::relation_to_attributes' do
    let(:uuid) {
      Rails.root.join('spec/repos/gold0001-8cd1-41d4-9ec7-e2c331f6c7bc')
    }

    let(:table) { Deploy::AbstractTable.new('master_uuid', 'exam_masters', 'question', 'description') }

    let(:child_table) { Deploy::AbstractTable.new('id', 'option_masters', 'sentence') }

    let(:expect_attributes) {
      [
        { id: ids[0], sentence: "選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。\nこの選択肢は１番目です。\n" },
        { id: ids[1], sentence: "選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。\nこの選択肢は２番目です。\n" },
        { id: ids[2], sentence: "選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。\nこの選択肢は３番目です。\n" },
        { id: ids[3], sentence: "選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。選択肢です。\nこの選択肢は４番目です。\n" },
      ]
    }

    before do
      table.has_many(child_table, 4)
    end

    context 'when OptionMaster record is NOT saved' do
      let(:ids) {
        []
      }

      it 'builds an array to save related table' do
        expect(Deploy::relation_to_attributes(uuid, table, ids)).to match_array(expect_attributes)
      end
    end

    context 'when OptionMaster record is saved' do
      let(:ids) {
        [40, 20, 30, 10]
      }

      it 'builds an array to save related table' do
        expect(Deploy::relation_to_attributes(uuid, table, ids)).to match_array(expect_attributes)
      end
    end
  end
end
