import { nextTick } from 'vue';
import { GlButton, GlFormInput } from '@gitlab/ui';

import FormUrlMaskItem from '~/webhooks/components/form_url_mask_item.vue';

import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

describe('FormUrlMaskItem', () => {
  let wrapper;

  const defaultProps = {
    index: 0,
  };
  const mockKey = 'key';
  const mockValue = 'value';
  const mockInput = 'input';

  const createComponent = ({ props } = {}) => {
    wrapper = shallowMountExtended(FormUrlMaskItem, {
      propsData: { ...defaultProps, ...props },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findMaskItemKey = () => wrapper.findByTestId('mask-item-key');
  const findMaskItemValue = () => wrapper.findByTestId('mask-item-value');
  const findRemoveButton = () => wrapper.findComponent(GlButton);

  describe('template', () => {
    it('renders input for key and value', () => {
      createComponent();

      const keyInput = findMaskItemKey();
      expect(keyInput.attributes('label')).toBe(FormUrlMaskItem.i18n.keyLabel);
      expect(keyInput.findComponent(GlFormInput).attributes('name')).toBe(
        'hook[url_variables][][key]',
      );

      const valueInput = findMaskItemValue();
      expect(valueInput.attributes('label')).toBe(FormUrlMaskItem.i18n.valueLabel);
      expect(valueInput.findComponent(GlFormInput).attributes('name')).toBe(
        'hook[url_variables][][value]',
      );
    });

    describe('on key input', () => {
      beforeEach(async () => {
        createComponent({ props: { itemKey: mockKey, itemValue: mockValue } });

        findMaskItemKey().findComponent(GlFormInput).vm.$emit('input', mockInput);
        await nextTick();
      });

      it('emits input event', () => {
        expect(wrapper.emitted('input')).toEqual([
          [{ index: defaultProps.index, key: mockInput, value: mockValue }],
        ]);
      });
    });

    describe('on value input', () => {
      beforeEach(async () => {
        createComponent({ props: { itemKey: mockKey, itemValue: mockValue } });

        findMaskItemValue().findComponent(GlFormInput).vm.$emit('input', mockInput);
        await nextTick();
      });

      it('emits input event', () => {
        expect(wrapper.emitted('input')).toEqual([
          [{ index: defaultProps.index, key: mockKey, value: mockInput }],
        ]);
      });
    });

    it('renders remove button', () => {
      createComponent();

      expect(findRemoveButton().props('icon')).toBe('remove');
    });

    describe('when remove button is clicked', () => {
      const mockIndex = 5;

      beforeEach(async () => {
        createComponent({ props: { index: mockIndex } });

        findRemoveButton().vm.$emit('click');
        await nextTick();
      });

      it('emits remove event', () => {
        expect(wrapper.emitted('remove')).toEqual([[mockIndex]]);
      });
    });
  });
});
