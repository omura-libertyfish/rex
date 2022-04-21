# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210921051220) do

  create_table "exam_histories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "exam_type"
    t.integer  "score",              default: 0
    t.integer  "review_later_count", default: 0
    t.integer  "continuous_times",   default: 0
    t.boolean  "pending",            default: true
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "exam_masters", force: :cascade do |t|
    t.string   "master_uuid"
    t.text     "question"
    t.text     "description"
    t.integer  "exam_type"
    t.integer  "answer_1_id"
    t.integer  "answer_2_id"
    t.integer  "answer_3_id"
    t.integer  "answer_4_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "category"
  end

  create_table "option_masters", force: :cascade do |t|
    t.text     "sentence"
    t.integer  "exam_master_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "user_answers", force: :cascade do |t|
    t.string   "url_uuid"
    t.integer  "exam_no"
    t.string   "type"
    t.integer  "exam_history_id"
    t.integer  "exam_master_id"
    t.integer  "answer_1_id"
    t.integer  "answer_2_id"
    t.integer  "answer_3_id"
    t.integer  "answer_4_id"
    t.integer  "score"
    t.boolean  "review_later",    default: false
    t.string   "prev_url_uuid"
    t.string   "next_url_uuid"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["exam_history_id"], name: "index_user_answers_on_exam_history_id"
    t.index ["url_uuid"], name: "index_user_answers_on_url_uuid"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.integer  "best_gold_score",   default: 0
    t.integer  "best_silver_score", default: 0
    t.integer  "continuous_times",  default: 0
    t.string   "provider"
    t.text     "uid"
    t.string   "oauth_token"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

end
