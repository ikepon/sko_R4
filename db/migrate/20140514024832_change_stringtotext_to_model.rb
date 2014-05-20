class ChangeStringtotextToModel < ActiveRecord::Migration
  def self.up
    change_column( :learnings, :memo, :text)
    change_column( :messages, :message_content, :text)
    change_column( :faqs, :question, :text)
    change_column( :faq_categories, :faq_category_summary, :text)
    change_column( :contacts, :content, :text)
    change_column( :agreements, :content, :text)
    change_column( :privacies, :content, :text)
  end

  def self.down
    change_column( :learnings, :memo, :string)
    change_column( :messages, :message_content, :string)
    change_column( :faqs, :question, :string)
    change_column( :faq_categories, :faq_category_summary, :string)
    change_column( :contacts, :content, :string)
    change_column( :agreements, :content, :string)
    change_column( :privacies, :content, :string)
  end
end