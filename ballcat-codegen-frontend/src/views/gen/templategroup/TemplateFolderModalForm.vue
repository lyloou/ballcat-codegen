<template>
  <a-modal
    :title="title"
    :visible="visible"
    :confirm-loading="submitLoading"
    @ok="handleSubmit"
    @cancel="handleClose"
  >
    <a-form :form="form" :label-col="labelCol" :wrapper-col="wrapperCol">
      <template v-if="isCreateForm">
        <a-form-item style="display: none">
          <a-input v-decorator="['groupId']" />
        </a-form-item>
        <a-form-item style="display: none">
          <a-input v-decorator="['parentId']" />
        </a-form-item>
        <a-form-item style="display: none">
          <a-input v-decorator="['type']" />
        </a-form-item>
        <a-form-item label="父目录">
          <span> {{ parentFileName }}</span>
        </a-form-item>
      </template>
      <template v-if="isUpdateForm">
        <a-form-item style="display: none">
          <a-input v-decorator="['id']" />
        </a-form-item>
      </template>
      <a-form-item label="文件名">
        <a-input v-decorator="['fileName']" placeholder="请输入文件名" />
      </a-form-item>
    </a-form>
  </a-modal>
</template>

<script>
import { PopUpFormMixin } from '@/mixins'
import { addObj, putObj } from '@/api/gen/templatedirectoryentry'

export default {
  name: 'TemplateEntryAddModalForm',
  mixins: [PopUpFormMixin],
  data() {
    return {
      reqFunctions: {
        create: addObj,
        update: putObj
      },

      labelCol: {
        sm: { span: 24 },
        md: { span: 3 }
      },
      wrapperCol: {
        sm: { span: 24 },
        md: { span: 20 }
      },

      // 父级文件名
      parentFileName: ''
    }
  },
  methods: {
    add(attributes) {
      this.buildCreatedForm()
      this.parentFileName = attributes.parentFileName
      this.fillFormData(attributes.formData)
      this.show(attributes)
    }
  }
}
</script>

<style scoped></style>
