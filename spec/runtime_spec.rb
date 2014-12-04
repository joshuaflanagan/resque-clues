require 'spec_helper'

module Resque
  module Plugins
    module Clues
      describe Runtime do
        before {Runtime.clear!}
        let(:original_metadata) { {'a' => 1} }

        describe "class instance methods" do
          before { Runtime.expose_metadata_to_job original_metadata }

          describe "#job_copy_of_metadata" do
            it "should allow reading the metadata exposed by the runtime to the job" do
              expect(Runtime.job_copy_of_metadata).to eq(original_metadata)
            end

            it "should constrain visibility to the executing thread" do
              Thread.new {Runtime.expose_metadata_to_job({'b' => 2})}.join
              expect(Runtime.job_copy_of_metadata.keys).to_not include('b')
            end

            it "should dupe the metadata so that its not directly modifiable" do
              Runtime.job_copy_of_metadata['b'] = 2
              expect(Runtime.job_copy_of_metadata.keys).to match_array(['a', 'b'])
              expect(original_metadata.keys).to match_array(['a'])
            end
          end

          describe "#store_changes_from_job" do
            it "should merge changes the job made back to the hash used for rescue clues events" do
              Runtime.job_copy_of_metadata['b'] = 2
              Runtime.store_changes_from_job(original_metadata)
              expect(original_metadata).to eq({'a' => 1, 'b' => 2})
            end

            it "should not overwrite existing values" do
              Runtime.job_copy_of_metadata['a'] = 2
              Runtime.store_changes_from_job(original_metadata)
              expect(original_metadata).to eq({'a' => 1})
            end

            it "should convert symbol keys to strings to preserve payload integrity" do
              Runtime.job_copy_of_metadata[:b] = 2
              Runtime.store_changes_from_job(original_metadata)
              expect(original_metadata).to eq({'a' => 1, 'b' => 2})
            end
          end
        end

        describe "mixin methods" do
          subject {Object.new.extend(Runtime)}

          describe "#clues_metadata" do
            it "should allow access to the job's copy of clues metadata once a runtime context is established" do
              Runtime.expose_metadata_to_job original_metadata
              expect(subject.clues_metadata).to eq(original_metadata)
            end
          end
        end
      end
    end
  end
end
