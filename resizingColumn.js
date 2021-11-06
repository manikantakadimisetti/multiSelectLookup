import { LightningElement } from 'lwc';
import fetchDataHelper from './fetchDataHelper';

const columns = [
    { label: 'Label', fieldName: 'name' },
    { label: 'Website', fieldName: 'website', type: 'url' },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
    { label: 'Balance', fieldName: 'amount', type: 'currency' },
    { label: 'CloseAt', fieldName: 'closeAt', type: 'date' },
];
//Added to git remote to respiratory
export default class resizingColumn extends LightningElement {
    inputValue;
    childObj;
    parObj;
    methodcalled='';
    mouseStart;
    oldWidth;
    offset;
      calculateWidth (event) {
          this.offset=event.target.parentNode.offsetWidth;
          this.inputValue=event.clientX;
            this.childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
           // this.inputValue=parObj.tagName;
            this.mouseStart=event.clientX;
            
            this.oldWidth=parObj.offsetWidth;
    }
    setNewWidth(event) {
        this.methodcalled = 'setWibth'
           var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            var newWidth = event.clientX
            this.inputValue=newWidth;
            parObj.style.width = newWidth+'px'; 
    }

  data = [];
    columns = columns;

    // eslint-disable-next-line @lwc/lwc/no-async-await
    async connectedCallback() {
        const data = await fetchDataHelper({ amountOfRecords: 100 });
        this.data = data;
    }
}
