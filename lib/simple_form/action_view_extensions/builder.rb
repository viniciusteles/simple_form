module SimpleForm
  module ActionViewExtensions
    # A collection of methods required by simple_form but added to rails default form.
    # This means that you can use such methods outside simple_form context.
    module Builder

      # Create a collection of radio inputs for the attribute. Basically this
      # helper will create a radio input associated with a label for each
      # text/value option in the collection, using value_method and text_method
      # to convert these text/value. Based on collection_select.
      #
      # == Examples
      #
      #   form_for @user do |f|
      #     f.collection_radio :options, [[true, 'Yes'] ,[false, 'No']], :first, :last
      #   end
      #
      #   <input id="user_options_true" name="user[options]" type="radio" value="true" />
      #   <label class="collection_radio" for="user_options_true">Yes</label>
      #   <input id="user_options_false" name="user[options]" type="radio" value="false" />
      #   <label class="collection_radio" for="user_options_false">No</label>
      #
      # == Options
      #
      # Collection radio accepts some extra options:
      #
      #   * checked  => the value that should be checked initially.
      #
      #   * disabled => the value or values that should be disabled. Accepts a single
      #                 item or an array of items.
      #
      def collection_radio(attribute, collection, value_method, text_method, options={}, html_options={})
        collection.map do |item|
          value = value_for_collection(item, value_method)
          text  = value_for_collection(item, text_method)
          default_html_options = default_html_options_for_collection(item, value, options, html_options)

          radio = radio_button(attribute, value, default_html_options)
          collection_label(attribute, value, radio, text, :class => "collection_radio")
        end.join.html_safe
      end

      # Creates a collection of check boxes for each item in the collection, associated
      # with a clickable label. Use value_method and text_method to convert items in
      # the collection for use as text/value in check boxes.
      #
      # == Examples
      #
      #   form_for @user do |f|
      #     f.collection_check_boxes :options, [[true, 'Yes'] ,[false, 'No']], :first, :last
      #   end
      #
      #   <input name="user[options][]" type="hidden" value="" />
      #   <input id="user_options_true" name="user[options][]" type="checkbox" value="true" />
      #   <label class="collection_check_boxes" for="user_options_true">Yes</label>
      #   <input name="user[options][]" type="hidden" value="" />
      #   <input id="user_options_false" name="user[options][]" type="checkbox" value="false" />
      #   <label class="collection_check_boxes" for="user_options_false">No</label>
      #
      # == Options
      #
      # Collection check box accepts some extra options:
      #
      #   * checked  => the value or values that should be checked initially. Accepts
      #                 a single item or an array of items.
      #
      #   * disabled => the value or values that should be disabled. Accepts a single
      #                 item or an array of items.
      #
      def collection_check_boxes(attribute, collection, value_method, text_method, options={}, html_options={})
        collection.map do |item|
          value = value_for_collection(item, value_method)
          text  = value_for_collection(item, text_method)
          default_html_options = default_html_options_for_collection(item, value, options, html_options)
          default_html_options[:multiple] = true

          check_box = check_box(attribute, default_html_options, value, '')
          collection_label(attribute, value, check_box, text, :class => "collection_check_boxes")
        end.join.html_safe
      end

      # Wrapper for using simple form inside a default rails form.
      # Example:
      #
      #   form_for @user do |f|
      #     f.simple_fields_for :posts do |posts_form|
      #       # Here you have all simple_form methods available
      #       posts_form.input :title
      #     end
      #   end
      def simple_fields_for(*args, &block)
        options = args.extract_options!
        options[:builder] = SimpleForm::FormBuilder
        fields_for(*(args << options), &block)
      end

    private

      # Wraps the given component in a label, for better accessibility with collections.
      def collection_label(attribute, value, component_tag, label_text, html_options) #:nodoc:
        label(sanitize_attribute_name(attribute, value), component_tag << label_text.to_s, html_options)
      end

      # Generate default options for collection helpers, such as :checked and
      # :disabled.
      def default_html_options_for_collection(item, value, options, html_options) #:nodoc:
        html_options = html_options.dup

        [:checked, :disabled].each do |option|
          next unless options[option]

          accept = if options[option].is_a?(Proc)
            options[option].call(item)
          else
            Array(options[option]).include?(value)
          end

          html_options[option] = true if accept
        end

        html_options
      end

      def sanitize_attribute_name(attribute, value)
        "#{attribute}_#{value.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase}"
      end


      def value_for_collection(item, value) #:nodoc:
        value.respond_to?(:call) ? value.call(item) : item.send(value)
      end
    end
  end
end

ActionView::Helpers::FormBuilder.send :include, SimpleForm::ActionViewExtensions::Builder
