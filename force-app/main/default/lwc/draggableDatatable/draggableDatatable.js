import { api, LightningElement, track } from "lwc";

export default class DraggableTable extends LightningElement {
    @track dragStart;
    @track ElementList = [];

    classList;

    @api
    get rows() {
        return this.ElementList;
    }

    set rows(value) {
        this.ElementList = value.map((element, index) => {
            return {
                ...element,
                Index__c: index
            };
        });
    }

    DragStart(event) {
        if (this.classList !== event.target.classList) {
            this.prevClassList = this.classList;
        }

        this.dragStart = event.target.title;
        this.classList = event.target.classList;
        this.classList.add("drag");
        this.prevClassList.remove("drag");
    }

    DragOver(event) {
        event.preventDefault();

        const DragValName = this.dragStart;
        const DropValName = event.target.title;

        if (DropValName === "") {
            return false;
        }

        if (DragValName === DropValName) {
            return false;
        }

        const currentIndex = DragValName;
        const newIndex = DropValName;

        Array.prototype.move = function (from, to) {
            this.splice(to, 0, this.splice(from, 1)[0]);
        };

        this.ElementList.move(currentIndex, newIndex);

        this.dragStart = DropValName;

        return false;
    }

    Drop(event) {
        event.stopPropagation();

        this.classList.remove("drag");

        this.dispatchEvent(new CustomEvent("reorder", {
            detail: this.ElementList
        }));
    }
}