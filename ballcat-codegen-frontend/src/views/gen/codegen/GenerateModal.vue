<template>
  <div>
    <a-modal
      title="属性配置"
      cancel-text="取消"
      :visible="visible"
      :body-style="{paddingBottom: '8px'}"
      :confirm-loading="submitLoading"
      :width="900"
      @cancel="handleClose"
    >
      <template slot="footer">
        <a-button @click="handleClose">
          取消
        </a-button>
        <a-button v-if="'single' === type" @click="previewCode">
          预览
        </a-button>
        <a-button type="primary" @click="handleOk">
          确认
        </a-button>
      </template>
      <a-form :form="form">
        <a-row :gutter="6">
          <a-col :span="10">
            <a-form-item :label-col="labelCol" :wrapper-col="wrapperCol" label="模板组">
              <a-select
                v-decorator="[
                  'templateGroupId',
                  {
                    initialValue: templateGroupIdInitValue,
                    rules: [{ required: true, message: '必须选择一个模板组' }]
                  }
                ]"
                @change="onTemplateGroupChange"
              >
                <a-select-option v-for="item in templateGroupSelectData" :key="Number(item.value)">
                  {{ item.name }}
                </a-select-option>
              </a-select>
            </a-form-item>
            <a-form-item label="生成文件选择">
              <div :style="{ borderBottom: '1px solid #E9E9E9' }">
                <a-checkbox :indeterminate="indeterminate" :checked="checkAll" @change="onCheckAllChange">
                  Check all
                </a-checkbox>
              </div>
              <a-checkbox-group
                v-decorator="['templateFileIds', { initialValue: templateFileIds }]"
                style="width: 100%;"
                @change="onTemplateFileIdsChange"
              >
                <a-row>
                  <template v-for="item in templateFiles">
                    <a-col :key="item.id" :span="12">
                      <a-checkbox :value="item.directoryEntryId">
                        {{ item.title }}
                      </a-checkbox>
                    </a-col>
                  </template>
                </a-row>
              </a-checkbox-group>
            </a-form-item>
          </a-col>
          <a-col :span="14">
            <a-divider orientation="left">
              系统属性
            </a-divider>
            <a-form-item :label-col="labelCol" :wrapper-col="wrapperCol" label="表前缀">
              <a-input v-decorator="['tablePrefix']" placeholder="填写则会将表名的前缀截取后，再生成类名" />
            </a-form-item>
            <a-divider orientation="left">
              自定义属性
            </a-divider>
            <a-form-item
              v-for="item in properties"
              :key="item.id"
              :label-col="labelCol"
              :wrapper-col="wrapperCol"
              :label="item.propKey"
            >
              <a-input
                v-decorator="[
                  'genProperties.' + item.propKey,
                  {
                    rules: [{ required: item.required === 1, message: item.title + '不能为空' }],
                    initialValue: item.defaultValue
                  }
                ]"
                :placeholder="'请输入' + item.title"
              />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>

    <generate-preview-modal ref="previewModal" />
  </div>
</template>

<script>
import { PopUpFormMixin } from '@/mixins'
import { getSelectData } from '@/api/gen/templategroup'
import { getProperties } from '@/api/gen/templateproperty'
import { getList as getTemplateFiles } from '@/api/gen/templateinfo'
import { generate, preview } from '@/api/gen/generate'
import GeneratePreviewModal from '@/views/gen/codegen/GeneratePreviewModal'

export default {
  name: 'GenerateModalForm',
  components: { GeneratePreviewModal },
  mixins: [PopUpFormMixin],
  props: {
    dsName: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      labelCol: {
        xs: { span: 12 },
        sm: { span: 24 },
        lg: { span: 6 }
      },
      wrapperCol: {
        xs: { span: 12 },
        sm: { span: 24 },
        lg: { span: 18 }
      },
      tableNames: [],
      templateGroupSelectData: [],
      templateGroupIdInitValue: null,

      properties: [],

      templateFiles: [],
      templateFileIds: [],
      checkedList: [],
      indeterminate: false,
      checkAll: true,

      type: ''
    }
  },
  methods: {
    show(tableNames, type) {
      getSelectData().then(res => {
        const data = res.data
        this.templateGroupSelectData = res.data
        if (data && data.length > 0) {
          const templateGroupId = Number(data[0].value)
          this.templateGroupIdInitValue = templateGroupId
          this.onTemplateGroupChange(templateGroupId)
          this.submitLoading = false
          this.visible = true
          this.type = type
          this.tableNames = tableNames
        }
      })
    },
    onTemplateGroupChange(templateGroupId) {
      getProperties(templateGroupId).then(res => {
        this.properties = res.data
      })
      getTemplateFiles(templateGroupId).then(res => {
        this.templateFiles = res.data
        this.templateFileIds = this.templateFiles.map(x => x.directoryEntryId)
      })
    },
    handleOk() {
      // 钩子函数 处理提交之前处理的事件
      this.form.validateFields((err, values) => {
        if (!err) {
          this.submitLoading = true
          generate(this.dsName, this.submitDataProcess(values))
            .then(fileBlob => {
              const blob = new Blob([fileBlob])
              const fileName = 'BallCat-CodeGen.zip'
              const eLink = document.createElement('a')
              if ('download' in eLink) {
                // 非IE下载
                eLink.download = fileName
                eLink.style.display = 'none'
                eLink.href = URL.createObjectURL(blob)
                document.body.appendChild(eLink)
                eLink.click()
                URL.revokeObjectURL(eLink.href) // 释放URL 对象
                document.body.removeChild(eLink)
              } else {
                // IE10+下载
                navigator.msSaveBlob(blob, fileName)
              }
            })
            .catch(() => {
              this.$message.error('代码生成异常')
            })
            .finally(() => {
              this.submitLoading = false
            })
        }
      })
    },
    previewCode() {
      this.form.validateFields((err, values) => {
        if (!err) {
          this.submitLoading = true
          preview(this.dsName, this.submitDataProcess(values))
            .then(res => {
              this.$refs.previewModal.show(res.data)
            })
            .catch(() => {
              this.$message.error('代码生成异常')
            })
            .finally(() => {
              this.submitLoading = false
            })
        }
      })
    },
    submitDataProcess(data) {
      data.tableNames = this.tableNames
      return data
    },
    onTemplateFileIdsChange(checkedList) {
      this.indeterminate = !!checkedList.length && checkedList.length < this.templateFileIds.length
      this.checkAll = checkedList.length === this.templateFileIds.length
    },
    onCheckAllChange(e) {
      this.indeterminate = false
      this.checkAll = e.target.checked
      this.fillFormData({ templateFileIds: this.checkAll ? this.templateFileIds : [] })
    }
  }
}
</script>
<style scoped>
.ant-form-item {
  margin-bottom: 8px;
}
</style>
