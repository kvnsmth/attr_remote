require 'active_record'
require 'active_support'
require 'active_resource'

module AttrRemote
  module ClassMethods
    def remote_attributes
      @remote_attributes ||= []
    end
    
    def remote_changed?
      @remote_changed == true
    end
    
    def attr_remote(*remote_attrs)
      remote_class = "Remote#{self.to_s}"
      remote_instance_meth = remote_class.underscore
      remote_instance_id = remote_class.foreign_key
      
      remote_attributes.concat(remote_attrs).uniq!
    
      class_eval <<-remote_access
  # def remote_user
  #   @remote_user ||= RemoteUser.find(self.remote_user_id) rescue nil
  # end
    def #{remote_instance_meth}
      @#{remote_instance_meth} ||= #{remote_class}.find(self.#{remote_instance_id}) rescue nil
    end
  
  # before_create :create_remote_user
    before_create :create_#{remote_instance_meth}
  
  # def create_remote_user
  #   unless self.remote_user_id
  #     remote_hash = {}
  #     self.class.remote_attributes.each do |attr|
  #       remote_hash[attr.to_sym] = self.send(attr.to_sym)
  #     end
  #     remote_hash[:validate_only] = true if validate_only
  #     @remote_user = RemoteUser.create(remote_hash)
  #     
  #     unless @remote_user.valid?
  #       @remote_user.errors.each do |attr, err|
  #         errors.add(attr, err)
  #       end
  #       return false
  #     else
  #       self.remote_user_id = @remote_user.id
  #     end
  #   end
  # end
    def create_#{remote_instance_meth}
      unless self.#{remote_instance_id}
        remote_hash = {}
        self.class.remote_attributes.each do |attr|
          remote_hash[attr.to_sym] = self.send(attr.to_sym)
        end
        @#{remote_instance_meth} = #{remote_class}.create(remote_hash)
        
        unless @#{remote_instance_meth}.valid?
          @#{remote_instance_meth}.errors.each do |attr, err|
            errors.add(attr, err)
          end
          return false
        else
          self.#{remote_instance_id} = @#{remote_instance_meth}.id
        end
      end
    end
    private :create_#{remote_instance_meth}
    
  # validate_on_create :validate_remote_user_on_create
    validate_on_create :validate_#{remote_instance_meth}_on_create
    
  # def validate_remote_user_on_create; end  
    def validate_#{remote_instance_meth}_on_create; end
    
  # before_update :update_remote_user  
    before_update :update_#{remote_instance_meth}
    
  # def update_remote_user
  #   if self.remote_user_id and self.class.remote_changed?
  #     remote_hash = {}
  #     self.class.remote_attributes.each do |attr|
  #       remote_hash[attr.to_sym] = self.send(attr.to_sym)
  #     end
  #     remote_user.load(remote_hash)
  #     remote_user.save
  #     
  #     unless @#{remote_instance_meth}.valid?
  #       remote_user.errors.each do |attr, err|
  #         errors.add(attr, err)
  #       end
  #       return false
  #     else
  #       @remote_changed = false
  #       return true
  #     end
  #   end
  # end
    def update_#{remote_instance_meth}
      if self.#{remote_instance_id} and self.class.remote_changed?
        remote_hash = {}
        self.class.remote_attributes.each do |attr|
          remote_hash[attr.to_sym] = self.send(attr.to_sym)
        end
        #{remote_instance_meth}.load(remote_hash)
        #{remote_instance_meth}.save
        
        unless @#{remote_instance_meth}.valid?
          #{remote_instance_meth}.errors.each do |attr, err|
            errors.add(attr, err)
          end
          return false
        else
          @remote_changed = false
          return true
        end
      end
    end
    private :update_#{remote_instance_meth}
    
  # validate_on_update :validate_remote_user_on_update
    validate_on_update :validate_#{remote_instance_meth}_on_update
    
  # def validate_remote_user_on_update; end  
    def validate_#{remote_instance_meth}_on_update; end
remote_access

      remote_attributes.each do |attr|      
        class_eval <<-remote_attribute
  def #{attr}                             # def username
    remote_#{attr} || ''                  #   remote_username || ''
  end                                     # end

  def remote_#{attr}                      # def remote_username
    if @#{attr}                           #   if @username
      @#{attr}                            #     @username
    elsif self.#{remote_instance_meth}    #   elsif self.remote_user
      @#{attr} = self.                    #     @username = self.
                 #{remote_instance_meth}. #                 remote_user.
                 #{attr} rescue nil       #                 username rescue nil
    else                                  #   else
      nil                                 #     nil
    end                                   #   end
  end                                     # end

  def #{attr}=(attr_value)                # def username=(attr_value)
    @#{attr} = attr_value                 #   @username = attr_value
    @remote_changed = true                #   @remote_changed = true
  end                                     # end
remote_attribute
      end
    end
  end
end

ActiveRecord::Base.extend AttrRemote::ClassMethods
