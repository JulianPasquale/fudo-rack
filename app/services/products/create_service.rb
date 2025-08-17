# frozen_string_literal: true

module Products
  class CreateService
    def create(name)
      # Schedule background job to create the product in 5 seconds
      CreateProductJob.perform_in(5.seconds, { 'name' => name })

      # Return a message indicating the product creation is pending
      'pending'
    end
  end
end
