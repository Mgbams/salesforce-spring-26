import { LightningElement, api } from 'lwc';

export default class NextBestActionTile extends LightningElement {
    @api actionId;
    @api actionLabel;
    @api description;
    @api category;
    @api iconName;

    dispatchPreview() {
        this.dispatchEvent(
            new CustomEvent('preview', {
                detail: {
                    actionId: this.actionId,
                    actionLabel: this.actionLabel,
                    description: this.description,
                    category: this.category
                }
            })
        );
    }

    dispatchExecute() {
        this.dispatchEvent(
            new CustomEvent('execute', {
                detail: {
                    actionId: this.actionId,
                    actionLabel: this.actionLabel
                }
            })
        );
    }

    // DOM event handlers
    handleMouseEnter = () => {
        this.dispatchPreview();
    };

    handleFocus = () => {
        this.dispatchPreview();
    };

    handleClick = () => {
        this.dispatchExecute();
    };

    // Dynamic event listener map for DOM events.
    // NOTE: Return a new object (don’t mutate) per the considerations doc.
    get domListeners() {
        return {
            click: this.handleClick,
            mouseenter: this.handleMouseEnter,
            focus: this.handleFocus
        };
    }
}
