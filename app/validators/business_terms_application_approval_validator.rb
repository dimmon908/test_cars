#encoding: utf-8
class BusinessTermsApplicationApprovalValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.user_id
      @term = TermsApplication::find_by_user_id value
      record.errors[:net_terms_not_approved] << I18n.t('activerecord.errors.models.request.attributes.status.term_request_unapproved') if @term && !@term.approved
    end
  end
end