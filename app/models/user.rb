# encoding: utf-8

# == Schema Information
#
# Table name: common.users
#
#  id                      :integer          not null, primary key
#  active                  :boolean          default(TRUE)
#  address                 :string
#  auth_token              :string
#  change_default_password :boolean          default(FALSE)
#  confirmation_sent_at    :datetime
#  confirmation_token      :string(60)
#  confirmed_at            :datetime
#  description             :string(255)
#  email                   :string           not null
#  encrypted_password      :string
#  first_name              :string(80)
#  last_name               :string(80)
#  last_sign_in_at         :datetime
#  locale                  :string           default("en")
#  mobile                  :string(40)
#  old_emails              :text             default([]), is an Array
#  password_salt           :string
#  phone                   :string(40)
#  reset_password_sent_at  :datetime
#  reset_password_token    :string
#  reseted_password_at     :datetime
#  rol                     :string(50)
#  sign_in_count           :integer          default(0)
#  website                 :string(200)
#  created_at              :datetime
#  updated_at              :datetime
#

# author: Boris Barroso
# email: boriscyber@gmail.com
class User < ActiveRecord::Base
  self.table_name = 'common.users'

  # Includes
  include Models::User::Authentication

  ROLES = %w(admin group other demo).freeze

  # Callbacks
  before_update :store_old_emails, if: :email_changed?

  ########################################
  # Relationships
  has_many :links, dependent: :destroy
  has_many :active_links, -> { where active: true }, inverse_of: :user, autosave: true,
           dependent: :destroy, class_name: 'Link'
  has_many :organisations, through: :active_links

  ########################################
  # Validations
  validates_email_format_of :email, message: I18n.t("errors.messages.user.email")
  validates :email, presence: true, uniqueness: {if: :email_changed?, message: I18n.t('errors.messages.email_taken')}

  with_options if: :change_password? do |u|
    u.validates :password, length: {within: PASSWORD_LENGTH..100 }
  end

  # Scopes
  scope :active, -> { where(active: true) }

  # Delegations
  ########################################
  delegate :name, :currency, :address, :tenant, to: :organisation, prefix: true, allow_nil: true

  def to_s
    if first_name.present? || last_name.present?
      %Q(#{first_name} #{last_name}).strip
    else
      %Q(#{email})
    end
  end

  def tenant_link(tenant)
    active_links.where(tenant: tenant).first
  end

  def active_links?
    active_links.any?
  end

  # Updates the priviledges of a user
  def update_user_role(params)
    self.link.update_attributes(role: params[:rolname], active: params[:active_link])
  end

  def set_auth_token
    self.update_attribute(:auth_token, SecureRandom.urlsafe_base64(32))
  end

  def reset_auth_token
    self.update_attribute(:auth_token, '')
  end

  def set_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32)
  end

  private

    def change_password?
      new_record? || !password.nil?
    end

    def valid_password_confirmation
      self.errors.add(:password, I18n.t('errors.messages.confirmation')) unless password === password_confirmation
    end

    def store_old_emails
      self.old_emails = [email_was] + old_emails
    end

end
