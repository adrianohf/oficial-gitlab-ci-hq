# frozen_string_literal: true
require "spec_helper"

RSpec.describe Pajamas::ButtonComponent, type: :component do
  subject do
    described_class.new(**options)
  end

  let(:content) { "Button content" }
  let(:options) { {} }

  describe 'basic usage' do
    before do
      render_inline(subject) do |c|
        content
      end
    end

    it 'renders its content' do
      expect(rendered_component).to have_text content
    end

    it 'adds default styling' do
      expect(rendered_component).to have_css ".btn.btn-default.btn-md.gl-button"
    end

    describe 'button_options' do
      let(:options) { { button_options: { id: 'baz', data: { foo: 'bar' } } } }

      it 'are added to the button' do
        expect(rendered_component).to have_css ".gl-button#baz[data-foo='bar']"
      end

      context 'with custom classes' do
        let(:options) { { variant: :danger, category: :tertiary, button_options: { class: 'custom-class' } } }

        it 'don\'t conflict with internal button_classes' do
          expect(rendered_component).to have_css '.gl-button.btn-danger.btn-danger-tertiary.custom-class'
        end
      end

      context 'overriding base attributes' do
        let(:options) { { button_options: { type: 'submit' } } }

        it 'overrides type' do
          expect(rendered_component).to have_css '[type="submit"]'
        end
      end
    end

    describe 'button_text_classes' do
      let(:options) { { button_text_classes: 'custom-text-class' } }

      it 'is added to the button text' do
        expect(rendered_component).to have_css ".gl-button-text.custom-text-class"
      end
    end

    describe 'disabled' do
      context 'by default (false)' do
        it 'does not have  disabled styling and behavior' do
          expect(rendered_component).not_to have_css ".disabled[disabled='disabled'][aria-disabled='true']"
        end
      end

      context 'when set to true' do
        let(:options) { { disabled: true } }

        it 'has disabled styling and behavior' do
          expect(rendered_component).to have_css ".disabled[disabled='disabled'][aria-disabled='true']"
        end
      end
    end

    describe 'loading' do
      context 'by default (false)' do
        it 'is not disabled' do
          expect(rendered_component).not_to have_css ".disabled[disabled='disabled']"
        end

        it 'does not render a spinner' do
          expect(rendered_component).not_to have_css ".gl-spinner[aria-label='Loading']"
        end
      end

      context 'when set to true' do
        let(:options) { { loading: true } }

        it 'is disabled' do
          expect(rendered_component).to have_css ".disabled[disabled='disabled']"
        end

        it 'renders a spinner' do
          expect(rendered_component).to have_css ".gl-spinner[aria-label='Loading']"
        end
      end
    end

    describe 'block' do
      context 'by default (false)' do
        it 'is inline' do
          expect(rendered_component).not_to have_css ".btn-block"
        end
      end

      context 'when set to true' do
        let(:options) { { block: true } }

        it 'is block element' do
          expect(rendered_component).to have_css ".btn-block"
        end
      end
    end

    describe 'selected' do
      context 'by default (false)' do
        it 'does not have selected styling and behavior' do
          expect(rendered_component).not_to have_css ".selected"
        end
      end

      context 'when set to true' do
        let(:options) { { selected: true } }

        it 'has selected styling and behavior' do
          expect(rendered_component).to have_css ".selected"
        end
      end
    end

    describe 'category & variant' do
      context 'with category variants' do
        where(:variant) { [:default, :confirm, :danger] }

        let(:options) { { variant: variant, category: :tertiary } }

        with_them do
          it 'renders the button in correct variant && category' do
            expect(rendered_component).to have_css(".#{described_class::VARIANT_CLASSES[variant]}")
            expect(rendered_component).to have_css(".#{described_class::VARIANT_CLASSES[variant]}-tertiary")
          end
        end
      end

      context 'with non-category variants' do
        where(:variant) { [:dashed, :link, :reset] }

        let(:options) { { variant: variant, category: :tertiary } }

        with_them do
          it 'renders the button in correct variant && category' do
            expect(rendered_component).to have_css(".#{described_class::VARIANT_CLASSES[variant]}")
            expect(rendered_component).not_to have_css(".#{described_class::VARIANT_CLASSES[variant]}-tertiary")
          end
        end
      end

      context 'with primary category' do
        where(:variant) { [:default, :confirm, :danger] }

        let(:options) { { variant: variant, category: :primary } }

        with_them do
          it 'renders the button in correct variant && category' do
            expect(rendered_component).to have_css(".#{described_class::VARIANT_CLASSES[variant]}")
            expect(rendered_component).not_to have_css(".#{described_class::VARIANT_CLASSES[variant]}-primary")
          end
        end
      end
    end

    describe 'size' do
      context 'by default (medium)' do
        it 'applies medium class' do
          expect(rendered_component).to have_css ".btn-md"
        end
      end

      context 'when set to small' do
        let(:options) { { size: :small } }

        it "applies the small class to the button" do
          expect(rendered_component).to have_css ".btn-sm"
        end
      end
    end

    describe 'icon' do
      it 'has none by default' do
        expect(rendered_component).not_to have_css ".gl-icon"
      end

      context 'with icon' do
        let(:options) { { icon: 'star-o', icon_classes: 'custom-icon' } }

        it 'renders an icon with custom CSS class' do
          expect(rendered_component).to have_css "svg.gl-icon.gl-button-icon.custom-icon[data-testid='star-o-icon']"
          expect(rendered_component).not_to have_css ".btn-icon"
        end
      end

      context 'with icon only and no content' do
        let(:content) { nil }
        let(:options) { { icon: 'star-o' } }

        it 'adds a "btn-icon" CSS class' do
          expect(rendered_component).to have_css ".btn.btn-icon"
        end
      end

      context 'with icon only and when loading' do
        let(:content) { nil }
        let(:options) { { icon: 'star-o', loading: true } }

        it 'renders only a loading icon' do
          expect(rendered_component).not_to have_css "svg.gl-icon.gl-button-icon.custom-icon[data-testid='star-o-icon']"
          expect(rendered_component).to have_css ".gl-spinner[aria-label='Loading']"
        end
      end
    end

    describe 'type' do
      context 'by default (without href)' do
        it 'has type "button"' do
          expect(rendered_component).to have_css "button[type='button']"
        end
      end

      context 'when set to known type' do
        where(:type) { [:button, :reset, :submit] }

        let(:options) { { type: type } }

        with_them do
          it 'has the correct type' do
            expect(rendered_component).to have_css "button[type='#{type}']"
          end
        end
      end

      context 'when set to unkown type' do
        let(:options) { { type: :madeup } }

        it 'has type "button"' do
          expect(rendered_component).to have_css "button[type='button']"
        end
      end

      context 'for links (with href)' do
        let(:options) { { href: 'https://example.com', type: :reset } }

        it 'ignores type' do
          expect(rendered_component).not_to have_css "[type]"
        end
      end
    end

    describe 'link button' do
      it 'renders a button tag with type="button" when "href" is not set' do
        expect(rendered_component).to have_css "button[type='button']"
      end

      context 'when "href" is provided' do
        let(:options) { { href: 'https://gitlab.com', target: '_blank' } }

        it "renders a link instead of the button" do
          expect(rendered_component).not_to have_css "button[type='button']"
          expect(rendered_component).to have_css "a[href='https://gitlab.com'][target='_blank']"
        end
      end
    end
  end
end
