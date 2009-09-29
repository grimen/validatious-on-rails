# encoding: utf-8
#
# Tap into the built-in form/input helpers to add validatious class names from
# model validations.
#
module ActionView
  module Helpers
    module FormHelper

      # Options-hash argument position for each helper:
      #
      # ActionView::Helpers::FormHelper
      #   text_field:3, password_field:3, file_field:3, text_area:3, check_box:3, radio_button:4
      #
      FIELD_TYPES_A = [:text_field, :password_field, :text_area, :check_box, :file_field].freeze
      FIELD_TYPES_B = [:radio_button].freeze
      FIELD_TYPES = FIELD_TYPES_A + FIELD_TYPES_B

      # Only options[:class] is interesting for this plugin - we want to set the class,
      # so the hooking of these helpers don't have to be very explicit.
      #
      FIELD_TYPES.each do |field_type|
        define_method "#{field_type}_with_validation".to_sym do |*args|
          case true
          when FIELD_TYPES_A.include?(field_type) then options_index = 2
          when FIELD_TYPES_B.include?(field_type) then options_index = 3
          end
          args[options_index] = ::ValidatiousOnRails::ModelValidations.options_for(args.first, args.second, args[options_index] || {})
          self.send "#{field_type}_without_validation", *args
        end
        alias_method_chain field_type, :validation
      end

      # Adds the title attribute to label tags when there is no title
      # set, and the label text is provided. The title is set to object_name.humanize
      #
      def label_with_title(object_name, method, text = nil, options = {})
        options[:title] ||= method.to_s.humanize unless text.nil?
        label_without_title(object_name, method, text, options)
      end
      alias_method_chain :label, :title

    end

    module FormOptionsHelper

      # Options-hash argument position for each helper:
      #
      # ActionView::Helpers::FormOptionsHelper
      #   time_zone_select:5, select:5, grouped_options_for_select:9, collection_select:7
      #
      FIELD_TYPES_A = [:time_zone_select, :select]
      FIELD_TYPES_B = [:collection_select]
      FIELD_TYPES_C = [:grouped_options_for_select]
      FIELD_TYPES = FIELD_TYPES_A + FIELD_TYPES_B + FIELD_TYPES_C

      FIELD_TYPES.each do |field_type|
        define_method "#{field_type}_with_validation".to_sym do |*args|
          case true
          when FIELD_TYPES_A.include?(field_type) then options_index = 4
          when FIELD_TYPES_B.include?(field_type) then options_index = 6
          when FIELD_TYPES_C.include?(field_type) then options_index = 8
          end
          args[options_index] = ::ValidatiousOnRails::ModelValidations.options_for(args.first, args.second, args[options_index] || {})
          self.send "#{field_type}_without_validation", *args
        end
        alias_method_chain field_type, :validation
      end

    end

    module DateHelper

      # Options-hash argument position for each helper:
      #
      # ActionView::Helpers::DateHelper
      #   select_date:3, select_datetime:3, select_time:3, select_year:3, select_month:3, select_day:3,
      #   select_hour:3, select_minute:3, select_second:3
      #
      # helpers matching: (a, b, options = {})
      FIELD_TYPES = [:select_date, :select_datetime, :select_time, :select_year,
                      :select_month, :select_day,:select_hour, :select_minute, :select_second]

      FIELD_TYPES.each do |field_type|
        define_method "#{field_type}_with_validation".to_sym do |*args|
          options_index = 2
          args[options_index] = ::ValidatiousOnRails::ModelValidations.options_for(args.first, args.second, args[options_index] || {})
          self.send "#{field_type}_without_validation", *args
        end
        alias_method_chain field_type, :validation
      end

    end

  end
end
