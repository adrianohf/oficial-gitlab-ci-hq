<script>
import { GlButton, GlButtonGroup, GlTooltipDirective as GlTooltip } from '@gitlab/ui';
import { s__ } from '~/locale';

export const i18n = {
  playTooltip: s__('PipelineSchedules|Run pipeline schedule'),
  editTooltip: s__('PipelineSchedules|Edit pipeline schedule'),
  deleteTooltip: s__('PipelineSchedules|Delete pipeline schedule'),
  takeOwnershipTooltip: s__('PipelineSchedules|Take ownership of pipeline schedule'),
};

export default {
  i18n,
  components: {
    GlButton,
    GlButtonGroup,
  },
  directives: {
    GlTooltip,
  },
  props: {
    schedule: {
      type: Object,
      required: true,
    },
  },
  computed: {
    canPlay() {
      return this.schedule.userPermissions.playPipelineSchedule;
    },
    canTakeOwnership() {
      return this.schedule.userPermissions.takeOwnershipPipelineSchedule;
    },
    canUpdate() {
      return this.schedule.userPermissions.updatePipelineSchedule;
    },
    canRemove() {
      return this.schedule.userPermissions.adminPipelineSchedule;
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-end">
    <gl-button-group>
      <gl-button v-if="canPlay" v-gl-tooltip :title="$options.i18n.playTooltip" icon="play" />
      <gl-button
        v-if="canTakeOwnership"
        v-gl-tooltip
        :title="$options.i18n.takeOwnershipTooltip"
        icon="user"
      />
      <gl-button v-if="canUpdate" v-gl-tooltip :title="$options.i18n.editTooltip" icon="pencil" />
      <gl-button
        v-if="canRemove"
        v-gl-tooltip
        :title="$options.i18n.deleteTooltip"
        icon="remove"
        variant="danger"
        data-testid="delete-pipeline-schedule-btn"
        @click="$emit('showDeleteModal', schedule.id)"
      />
    </gl-button-group>
  </div>
</template>
