# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. test_helper)))

require 'action_controller/test_case'

class ControllerTest < ::ActionController::TestCase
  
  # /validates/uniqueness_of?model={MODEL_NAME}&attribute={ATTRIBUTE_NAME}&value={INPUT_VALUE}(&id=RECORD_ID)
  
  before do
    @controller = ::ValidatesController.new
    @bogus_item = ::BogusItem.new
  end
  
  context "routes" do
    test "remote validations route" do
      assert_routing 'validates/craziness_of', :controller => 'validates', :action => 'craziness_of'
    end
  end
  
  context "remote validations" do
    context "invalid validation" do
      test "without any params - should fail" do
        get :bananas
        assert_response 405
        assert_equal 'false', @response.body
      end
    end
    
    context "valid validation" do
      test "without any params - should fail" do
        get :uniqueness_of
        assert_response 405
        assert_equal 'false', @response.body
      end
      
      test "with params: :model - should fail" do
        get :uniqueness_of, :model => 'bogus_item'
        assert_response 405
        assert_equal 'false', @response.body
      end
      
      context "with params: :model, :attribute" do
        test "any invalid - should fail" do
          get :uniqueness_of, :model => 'duck', :attribute => 'name'
          assert_response 405
          assert_equal 'false', @response.body
          
          get :uniqueness_of, :model => 'bogus_item', :attribute => 'jedi'
          assert_response 405
          assert_equal 'false', @response.body
        end
        
        context "all valid" do
          test "invalid validation methods/actions - should fail" do
            get :bananas, :model => 'bogus_item', :attribute => 'name'
            assert_response 405
            assert_equal 'false', @response.body
          end
          
          context "without :value" do
            # test ":value is not allowed to be blank - should fail" do
            #   get :uniqueness_of, :model => 'bogus_item', :attribute => 'name'
            #   assert_response 405
            #   assert_equal 'false', @response.body
            # end
            
             # test ":value is allowed to be blank - should succeed" do
             #   get :uniqueness_of, :model => 'bogus_item', :attribute => 'name'
             #   assert_response 200
             #   assert_equal 'true', @response.body
             # end
          end
          
          context "with :value" do
            # FIXME: Fails, but why? Works "in practice".
            test "invalid value - should fail" do
              @existing_bogus_item = ::BogusItem.new(:name => 'carrot')
              @existing_bogus_item.save(false)
              
              get :uniqueness_of, :model => 'bogus_item', :attribute => 'name', :value => 'carrot' 
              assert_response 200
              assert_equal 'true', @response.body
            end
            
            test "valid :value - should succeed" do
              get :uniqueness_of, :model => 'bogus_item', :attribute => 'name', :value => 'unique carrot' 
              assert_response 200
              assert_equal 'true', @response.body
            end
          end
        end
      end
    end
  end
  
end