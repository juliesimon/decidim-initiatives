# frozen_string_literal: true

shared_examples 'update an initiative' do
  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, organization: organization) }

  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_feature: nil,
      initiative: initiative
    )
  end

  describe 'call' do
    let(:initiative_type) { create(:initiatives_type, organization: organization) }
    let(:form_params) do
      {
        title: { en: 'A reasonable initiative title' },
        description: { en: 'A reasonable initiative description' },
        signature_start_time: Date.today + 10.days,
        signature_end_time: Date.today + 130.days,
        type_id: initiative_type.id,
        signature_type: 'any',
        answer: { en: 'Measured answer' },
        answer_url: 'http://decidim.org',
        hashtag: 'update_initiative_example'
      }
    end

    let(:command) do
      described_class.new(initiative, form, initiative.author)
    end

    describe 'when the form is not valid' do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it 'broadcasts invalid' do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't updates the initiative" do
        command.call

        form_params.each do |key, value|
          expect(initiative[key]).not_to eq(value)
        end
      end
    end

    describe 'when the form is valid' do
      it 'broadcasts ok' do
        expect { command.call }.to broadcast(:ok)
      end


      it 'updates the initiative' do
        command.call
        initiative.reload

        expect(initiative.title['en']).to eq(form_params[:title][:en])
        expect(initiative.description['en']).to eq(form_params[:description][:en])
        expect(initiative.answer['en']).to eq(form_params[:answer][:en])
        expect(initiative.type.id).to eq(form_params[:type_id])
        expect(initiative.signature_type).to eq(form_params[:signature_type])
        expect(initiative.answer_url).to eq(form_params[:answer_url])
        expect(initiative.hashtag).to eq(form_params[:hashtag])
      end

      it 'voting interval remains unchanged' do
        command.call
        initiative.reload

        %i[signature_start_time signature_end_time].each do |key|
          expect(initiative[key]).not_to eq(form_params[key])
        end
      end

      context 'Administrator user' do
        let(:administrator) { create(:user, :admin, organization: organization)}

        let(:command) do
          described_class.new(initiative, form, administrator)
        end

        it 'voting interval gets updated' do
          command.call
          initiative.reload

          %i[signature_start_time signature_end_time].each do |key|
            expect(initiative[key]).to eq(form_params[key])
          end
        end
      end
    end
  end
end